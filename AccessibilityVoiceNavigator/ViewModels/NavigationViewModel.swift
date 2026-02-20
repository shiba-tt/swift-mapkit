import Foundation
import MapKit
import Combine
import SwiftUI

/// ナビゲーション全体を制御するViewModel
@MainActor
final class NavigationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var navigationState: NavigationState = .idle
    @Published var searchQuery = ""
    @Published var searchResults: [SearchResultItem] = []
    @Published var selectedDestination: SearchResultItem?
    @Published var routeInfo: RouteInfo?
    @Published var currentStepIndex = 0
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671), // 東京駅
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var routePolyline: MKPolyline?
    @Published var showSearchResults = false
    @Published var estimatedArrivalTime: String?

    // MARK: - Services
    let locationManager = LocationManager()
    let routeSearchService = RouteSearchService()
    let voiceGuidanceService = VoiceGuidanceService()
    private let hapticService = HapticFeedbackService.shared

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var navigationMonitorTask: Task<Void, Never>?
    private let arrivalThreshold: CLLocationDistance = 20 // 20m以内で到着判定
    private let stepThreshold: CLLocationDistance = 30 // 30m以内で次のステップ
    private let offRouteThreshold: CLLocationDistance = 50 // 50m以上で経路逸脱

    // MARK: - Initialization
    init() {
        setupLocationUpdates()
    }

    // MARK: - Setup
    private func setupLocationUpdates() {
        locationManager.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.updateMapRegion(for: location.coordinate)
                self?.checkNavigationProgress(location: location)
            }
            .store(in: &cancellables)
    }

    // MARK: - Location
    func requestLocationPermission() {
        locationManager.requestAuthorization()
    }

    private func updateMapRegion(for coordinate: CLLocationCoordinate2D) {
        guard navigationState == .idle || navigationState == .routeFound else { return }
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }

    // MARK: - Search
    func searchDestination() async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        navigationState = .searching
        voiceGuidanceService.speak("検索中です。お待ちください。")

        let results = await routeSearchService.searchPlaces(
            query: searchQuery,
            region: mapRegion
        )

        searchResults = results
        showSearchResults = !results.isEmpty

        if results.isEmpty {
            voiceGuidanceService.speak("検索結果が見つかりませんでした。")
            navigationState = .idle
        } else {
            voiceGuidanceService.speak("\(results.count)件の結果が見つかりました。")
            navigationState = .idle
        }
    }

    /// 目的地を選択して経路を検索
    func selectDestination(_ item: SearchResultItem) async {
        selectedDestination = item
        showSearchResults = false
        searchQuery = item.name

        voiceGuidanceService.speak("\(item.name)を目的地に設定しました。経路を検索します。", priority: .high)
        hapticService.selectionFeedback()

        await calculateRoute(to: item.coordinate)
    }

    // MARK: - Route Calculation
    private func calculateRoute(to destination: CLLocationCoordinate2D) async {
        guard let source = locationManager.currentCoordinate else {
            navigationState = .error("現在地を取得できません")
            voiceGuidanceService.announceError("現在地を取得できません。位置情報の設定を確認してください。")
            hapticService.errorFeedback()
            return
        }

        navigationState = .searching

        do {
            let routes = try await routeSearchService.searchRoute(
                from: source,
                to: destination
            )

            guard let bestRoute = routes.first else {
                navigationState = .error("経路が見つかりませんでした")
                voiceGuidanceService.announceError("経路が見つかりませんでした。")
                return
            }

            routeInfo = bestRoute
            routePolyline = bestRoute.route.polyline
            navigationState = .routeFound

            // 地図を経路全体が見えるように調整
            let rect = bestRoute.route.polyline.boundingMapRect
            let padding = UIEdgeInsets(top: 80, left: 40, bottom: 200, right: 40)
            mapRegion = MKCoordinateRegion(rect.insetBy(dx: -rect.size.width * 0.1, dy: -rect.size.height * 0.1))

            // 到着予想時刻を取得
            estimatedArrivalTime = await routeSearchService.estimatedArrival(
                from: source,
                to: destination
            )

            // 経路概要を読み上げ
            let arrivalText = estimatedArrivalTime != nil ? "到着予想時刻は\(estimatedArrivalTime!)です。" : ""
            voiceGuidanceService.speak(
                "\(bestRoute.totalDistanceText)の経路が見つかりました。所要時間は\(bestRoute.totalTimeText)です。\(arrivalText)ナビゲーションを開始するには、開始ボタンをタップしてください。",
                priority: .high
            )

        } catch {
            navigationState = .error("経路検索に失敗しました")
            voiceGuidanceService.announceError("経路検索に失敗しました。ネットワーク接続を確認してください。")
            hapticService.errorFeedback()
        }
    }

    // MARK: - Navigation Control
    func startNavigation() {
        guard let routeInfo = routeInfo, !routeInfo.steps.isEmpty else { return }

        navigationState = .navigating
        currentStepIndex = 0
        hapticService.navigationStartFeedback()
        voiceGuidanceService.announceNavigationStart(routeInfo: routeInfo)

        // 最初のステップをアナウンス
        if let firstStep = routeInfo.steps.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.voiceGuidanceService.announceStep(firstStep)
            }
        }

        startNavigationMonitoring()
    }

    func stopNavigation() {
        navigationState = .idle
        navigationMonitorTask?.cancel()
        navigationMonitorTask = nil
        routeInfo = nil
        routePolyline = nil
        currentStepIndex = 0
        selectedDestination = nil
        estimatedArrivalTime = nil
        searchQuery = ""

        voiceGuidanceService.speak("ナビゲーションを終了しました。", priority: .immediate)
    }

    /// 現在のステップを再読み上げ
    func repeatCurrentStep() {
        guard let routeInfo = routeInfo,
              currentStepIndex < routeInfo.steps.count else { return }

        let step = routeInfo.steps[currentStepIndex]
        voiceGuidanceService.announceStep(step)
        hapticService.locationPulseFeedback()
    }

    /// 現在位置の状況を読み上げ
    func announceCurrentStatus() {
        guard let destination = selectedDestination,
              let distance = locationManager.distance(to: destination.coordinate) else {
            voiceGuidanceService.speak("現在の状況を取得できません。")
            return
        }

        let distanceText: String
        if distance < 1000 {
            distanceText = "\(Int(distance))メートル"
        } else {
            distanceText = String(format: "%.1fキロメートル", distance / 1000)
        }

        let direction = locationManager.relativeDirection(to: destination.coordinate)
        voiceGuidanceService.announceCurrentStatus(distance: distanceText, direction: direction)
        hapticService.locationPulseFeedback()
    }

    // MARK: - Navigation Monitoring
    private func startNavigationMonitoring() {
        navigationMonitorTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒ごと
                guard let self = self else { break }
                guard self.navigationState == .navigating else { break }

                if let location = self.locationManager.currentLocation {
                    self.checkNavigationProgress(location: location)
                }
            }
        }
    }

    private func checkNavigationProgress(location: CLLocation) {
        guard navigationState == .navigating,
              let routeInfo = routeInfo,
              let destination = selectedDestination else { return }

        // 目的地到着判定
        let distanceToDestination = location.distance(
            from: CLLocation(
                latitude: destination.coordinate.latitude,
                longitude: destination.coordinate.longitude
            )
        )

        if distanceToDestination <= arrivalThreshold {
            handleArrival()
            return
        }

        // 次のステップへの進行判定
        if currentStepIndex < routeInfo.steps.count - 1 {
            let nextStep = routeInfo.steps[currentStepIndex + 1]
            let distanceToNextStep = location.distance(
                from: CLLocation(
                    latitude: nextStep.coordinate.latitude,
                    longitude: nextStep.coordinate.longitude
                )
            )

            if distanceToNextStep <= stepThreshold {
                advanceToNextStep()
            } else if distanceToNextStep <= 50 {
                // 50m手前で予告アナウンス
                voiceGuidanceService.announceUpcomingTurn(
                    distance: Int(distanceToNextStep),
                    instruction: nextStep.instruction
                )
            }
        }
    }

    private func advanceToNextStep() {
        guard let routeInfo = routeInfo,
              currentStepIndex < routeInfo.steps.count - 1 else { return }

        currentStepIndex += 1
        let step = routeInfo.steps[currentStepIndex]
        voiceGuidanceService.announceStep(step)
        hapticService.turnFeedback()
    }

    private func handleArrival() {
        navigationState = .arrived
        navigationMonitorTask?.cancel()

        if let destination = selectedDestination {
            voiceGuidanceService.announceArrival(destination: destination.name)
        }
        hapticService.arrivalFeedback()
    }

    // MARK: - Computed Properties
    var currentStep: NavigationStep? {
        guard let routeInfo = routeInfo,
              currentStepIndex < routeInfo.steps.count else { return nil }
        return routeInfo.steps[currentStepIndex]
    }

    var remainingSteps: Int {
        guard let routeInfo = routeInfo else { return 0 }
        return max(0, routeInfo.steps.count - currentStepIndex - 1)
    }

    var progressPercentage: Double {
        guard let routeInfo = routeInfo, !routeInfo.steps.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(routeInfo.steps.count)
    }
}
