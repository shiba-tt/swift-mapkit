import Foundation
import MapKit
import Combine

/// 交通可視化のメインViewModel
@MainActor
final class TrafficViewModel: ObservableObject {

    // MARK: - Published プロパティ

    @Published var routes: [TrafficRoute] = []
    @Published var congestionPoints: [CongestionPoint] = []
    @Published var selectedRoute: TrafficRoute?
    @Published var showDetourRoutes: Bool = true
    @Published var showCongestionPoints: Bool = true
    @Published var showTrafficLayer: Bool = true
    @Published var isAutoRefreshing: Bool = false
    @Published var lastUpdated: Date?

    /// 表示するエリアの中心（渋谷〜新宿間）
    let defaultCenter = CLLocationCoordinate2D(latitude: 35.6750, longitude: 139.6980)
    let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)

    var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: defaultCenter, span: defaultSpan)
    }

    // MARK: - サービス

    private let dataService = TrafficDataService.shared

    // MARK: - 初期化

    init() {
        loadTrafficData()
    }

    // MARK: - データ操作

    /// 交通データを読み込み
    func loadTrafficData() {
        let data = dataService.refreshAllData()
        routes = data.routes
        congestionPoints = data.congestionPoints
        lastUpdated = Date()

        if selectedRoute == nil, let first = routes.first {
            selectedRoute = first
        }
    }

    /// 手動でデータを更新
    func refreshData() {
        loadTrafficData()
    }

    /// 自動更新の切り替え
    func toggleAutoRefresh() {
        isAutoRefreshing.toggle()

        if isAutoRefreshing {
            dataService.startAutoRefresh { [weak self] routes, points in
                Task { @MainActor in
                    self?.routes = routes
                    self?.congestionPoints = points
                    self?.lastUpdated = Date()
                }
            }
        } else {
            dataService.stopAutoRefresh()
        }
    }

    /// ルートを選択
    func selectRoute(_ route: TrafficRoute) {
        selectedRoute = route
    }

    // MARK: - 表示用プロパティ

    /// 表示するルート（フィルタ適用済み）
    var visibleRoutes: [TrafficRoute] {
        if showDetourRoutes {
            return routes
        }
        return routes.filter { !$0.isDetour }
    }

    /// 表示する渋滞ポイント
    var visibleCongestionPoints: [CongestionPoint] {
        showCongestionPoints ? congestionPoints : []
    }

    /// 全体の渋滞サマリー
    var trafficSummary: String {
        let heavyCount = congestionPoints.filter { $0.trafficLevel >= .heavy }.count
        let moderateCount = congestionPoints.filter { $0.trafficLevel == .moderate }.count

        if heavyCount == 0 && moderateCount == 0 {
            return "現在、主要な渋滞はありません"
        }

        var parts: [String] = []
        if heavyCount > 0 {
            parts.append("渋滞 \(heavyCount)箇所")
        }
        if moderateCount > 0 {
            parts.append("混雑 \(moderateCount)箇所")
        }
        return parts.joined(separator: "、")
    }

    /// 最終更新時刻の表示
    var lastUpdatedText: String {
        guard let date = lastUpdated else { return "未更新" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    /// 推奨ルート
    var recommendedRoute: TrafficRoute? {
        routes.min { a, b in
            a.estimatedTravelTimeSeconds < b.estimatedTravelTimeSeconds
        }
    }

    // MARK: - クリーンアップ

    func cleanup() {
        dataService.stopAutoRefresh()
        isAutoRefreshing = false
    }
}
