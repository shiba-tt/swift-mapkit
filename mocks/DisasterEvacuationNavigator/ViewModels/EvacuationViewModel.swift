import Foundation
import CoreLocation
import MapKit
import SwiftUI

/// 避難ナビのメインViewModel
@MainActor
final class EvacuationViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var shelters: [EvacuationShelter] = SampleData.shelters
    @Published var floodZones: [FloodZone] = SampleData.floodZones
    @Published var selectedShelter: EvacuationShelter?
    @Published var route: MKRoute?
    @Published var isLoadingRoute = false
    @Published var routeError: String?
    @Published var searchText = ""
    @Published var selectedShelterType: ShelterType?
    @Published var showFloodZones = true
    @Published var showOpenOnly = false
    @Published var sortByDistance = true
    @Published var estimatedTravelTime: String?
    @Published var estimatedDistance: String?
    @Published var showShelterList = false

    // MARK: - Dependencies

    let locationManager = LocationManager()

    // MARK: - Computed Properties

    /// フィルタリング・ソート済みの避難所リスト
    var filteredShelters: [EvacuationShelter] {
        var result = shelters

        // テキスト検索
        if !searchText.isEmpty {
            result = result.filter { shelter in
                shelter.name.localizedCaseInsensitiveContains(searchText) ||
                shelter.address.localizedCaseInsensitiveContains(searchText)
            }
        }

        // 種別フィルタ
        if let type = selectedShelterType {
            result = result.filter { $0.shelterTypes.contains(type) }
        }

        // 開設中のみ
        if showOpenOnly {
            result = result.filter { $0.isOpen }
        }

        // 距離順ソート
        if sortByDistance {
            let location = locationManager.effectiveLocation
            result.sort { $0.distance(from: location) < $1.distance(from: location) }
        }

        return result
    }

    /// 最寄りの避難所
    var nearestShelter: EvacuationShelter? {
        let location = locationManager.effectiveLocation
        return shelters
            .filter { $0.isOpen }
            .min { $0.distance(from: location) < $1.distance(from: location) }
    }

    /// マップの初期表示領域（東京都中心部）
    var initialRegion: MKCoordinateRegion {
        if let location = locationManager.currentLocation {
            return MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6896, longitude: 139.6917),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    }

    // MARK: - Methods

    /// 位置情報の初期化
    func setup() {
        locationManager.requestPermission()
    }

    /// 避難所を選択してルートを計算
    func selectShelter(_ shelter: EvacuationShelter) {
        selectedShelter = shelter
        calculateRoute(to: shelter)
    }

    /// 選択解除
    func clearSelection() {
        selectedShelter = nil
        route = nil
        estimatedTravelTime = nil
        estimatedDistance = nil
        routeError = nil
    }

    /// 最寄りの避難所へのルートを表示
    func navigateToNearest() {
        guard let nearest = nearestShelter else { return }
        selectShelter(nearest)
    }

    /// 避難所へのルートを計算
    func calculateRoute(to shelter: EvacuationShelter) {
        isLoadingRoute = true
        routeError = nil
        route = nil

        let request = MKDirections.Request()

        let sourcePlacemark = MKPlacemark(coordinate: locationManager.effectiveLocation.coordinate)
        request.source = MKMapItem(placemark: sourcePlacemark)

        let destPlacemark = MKPlacemark(coordinate: shelter.coordinate)
        request.destination = MKMapItem(placemark: destPlacemark)

        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoadingRoute = false

                if let error {
                    self.routeError = "ルート計算に失敗しました: \(error.localizedDescription)"
                    return
                }

                guard let route = response?.routes.first else {
                    self.routeError = "ルートが見つかりませんでした"
                    return
                }

                self.route = route
                self.estimatedTravelTime = self.formatTravelTime(route.expectedTravelTime)
                self.estimatedDistance = self.formatDistance(route.distance)
            }
        }
    }

    // MARK: - Private Helpers

    private func formatTravelTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "徒歩約\(minutes)分"
        }
        let hours = minutes / 60
        let remainMinutes = minutes % 60
        return "徒歩約\(hours)時間\(remainMinutes)分"
    }

    private func formatDistance(_ meters: CLLocationDistance) -> String {
        if meters < 1000 {
            return String(format: "%.0fm", meters)
        }
        return String(format: "%.1fkm", meters / 1000)
    }
}
