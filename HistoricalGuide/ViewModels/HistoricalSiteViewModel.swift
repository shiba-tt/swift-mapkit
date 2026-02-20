import Foundation
import MapKit
import Combine
import SwiftUI

/// 歴史散策ガイドのメインViewModel
@MainActor
final class HistoricalSiteViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 全史跡データ
    @Published var allSites: [HistoricalSite] = SampleHistoricalData.allSites

    /// 散策ルート
    @Published var routes: [WalkingRoute] = SampleHistoricalData.allRoutes

    /// 選択中の史跡
    @Published var selectedSite: HistoricalSite?

    /// 選択中のルート
    @Published var selectedRoute: WalkingRoute?

    /// 検索テキスト
    @Published var searchText: String = ""

    /// フィルタ: 時代
    @Published var selectedEraFilter: HistoricalEra?

    /// フィルタ: カテゴリ
    @Published var selectedCategoryFilter: SiteCategory?

    /// マップカメラ位置
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    /// お気に入りの史跡ID
    @Published var favoriteIDs: Set<UUID> = []

    /// AR表示中フラグ
    @Published var isShowingAR: Bool = false

    /// 詳細シート表示フラグ
    @Published var isShowingDetail: Bool = false

    /// ルート表示中フラグ
    @Published var isShowingRoute: Bool = false

    /// ルート上のポリライン座標
    @Published var routePolyline: [CLLocationCoordinate2D] = []

    // MARK: - Computed Properties

    /// フィルタ・検索適用後の史跡一覧
    var filteredSites: [HistoricalSite] {
        var sites = allSites

        if let era = selectedEraFilter {
            sites = sites.filter { $0.era == era }
        }

        if let category = selectedCategoryFilter {
            sites = sites.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            sites = sites.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.nameReading.localizedCaseInsensitiveContains(searchText)
                || $0.summary.localizedCaseInsensitiveContains(searchText)
                || $0.address.localizedCaseInsensitiveContains(searchText)
                || $0.era.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }

        return sites
    }

    /// 時代ごとにグループ化された史跡
    var sitesByEra: [(era: HistoricalEra, sites: [HistoricalSite])] {
        let grouped = Dictionary(grouping: filteredSites) { $0.era }
        return HistoricalEra.allCases.compactMap { era in
            guard let sites = grouped[era], !sites.isEmpty else { return nil }
            return (era: era, sites: sites)
        }
    }

    /// 選択中のルートに含まれる史跡
    var routeSites: [HistoricalSite] {
        guard let route = selectedRoute else { return [] }
        return route.siteIDs.compactMap { id in
            allSites.first { $0.id == id }
        }
    }

    // MARK: - Methods

    /// 史跡を選択して詳細を表示
    func selectSite(_ site: HistoricalSite) {
        selectedSite = site
        isShowingDetail = true
        moveCameraToSite(site)
    }

    /// カメラを史跡の位置に移動
    func moveCameraToSite(_ site: HistoricalSite) {
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: site.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }

    /// カメラを全史跡が見える範囲に移動
    func showAllSites() {
        let sites = filteredSites
        guard !sites.isEmpty else { return }

        let latitudes = sites.map { $0.latitude }
        let longitudes = sites.map { $0.longitude }

        let centerLat = (latitudes.min()! + latitudes.max()!) / 2
        let centerLon = (longitudes.min()! + longitudes.max()!) / 2
        let spanLat = (latitudes.max()! - latitudes.min()!) * 1.5 + 0.01
        let spanLon = (longitudes.max()! - longitudes.min()!) * 1.5 + 0.01

        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                    span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
                )
            )
        }
    }

    /// お気に入りの切り替え
    func toggleFavorite(for site: HistoricalSite) {
        if favoriteIDs.contains(site.id) {
            favoriteIDs.remove(site.id)
        } else {
            favoriteIDs.insert(site.id)
        }
    }

    /// 史跡がお気に入りかどうか
    func isFavorite(_ site: HistoricalSite) -> Bool {
        favoriteIDs.contains(site.id)
    }

    /// ルートを選択して地図上に表示
    func selectRoute(_ route: WalkingRoute) {
        selectedRoute = route
        isShowingRoute = true

        let sites = route.siteIDs.compactMap { id in
            allSites.first { $0.id == id }
        }

        routePolyline = sites.map { $0.coordinate }

        // ルート全体が見える範囲にカメラを移動
        guard !sites.isEmpty else { return }
        let latitudes = sites.map { $0.latitude }
        let longitudes = sites.map { $0.longitude }
        let centerLat = (latitudes.min()! + latitudes.max()!) / 2
        let centerLon = (longitudes.min()! + longitudes.max()!) / 2
        let spanLat = (latitudes.max()! - latitudes.min()!) * 1.5 + 0.02
        let spanLon = (longitudes.max()! - longitudes.min()!) * 1.5 + 0.02

        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                    span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
                )
            )
        }
    }

    /// ルートを解除
    func clearRoute() {
        selectedRoute = nil
        isShowingRoute = false
        routePolyline = []
    }

    /// フィルタをリセット
    func clearFilters() {
        selectedEraFilter = nil
        selectedCategoryFilter = nil
        searchText = ""
    }

    /// 特定の地域にカメラを移動
    func moveToRegion(_ region: MapRegion) {
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(region.coordinateRegion)
        }
    }

    /// AR表示を開始
    func showAR(for site: HistoricalSite) {
        selectedSite = site
        isShowingAR = true
    }
}

// MARK: - Map Region Presets

/// プリセット地域
enum MapRegion: String, CaseIterable, Identifiable {
    case kyoto = "京都"
    case tokyo = "東京"
    case nara = "奈良"
    case osaka = "大阪"
    case kamakura = "鎌倉"
    case himeji = "姫路"
    case hiroshima = "広島"
    case all = "全国"

    var id: String { rawValue }

    var coordinateRegion: MKCoordinateRegion {
        switch self {
        case .kyoto:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        case .tokyo:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        case .nara:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.6851, longitude: 135.8048),
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
        case .osaka:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.6937, longitude: 135.5023),
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        case .kamakura:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.3197, longitude: 139.5467),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        case .himeji:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.8394, longitude: 134.6939),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        case .hiroshima:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.2961, longitude: 132.3198),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        case .all:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.0, longitude: 136.0),
                span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
            )
        }
    }
}
