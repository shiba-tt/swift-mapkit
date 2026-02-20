import Foundation
import MapKit
import Observation
import SwiftUI

/// 商圏分析のメインViewModel
@Observable
final class TradeAreaViewModel {

    // MARK: - Published State

    /// 分析設定
    var config: TradeAreaConfig = .default

    /// 検出された競合店舗
    var competitors: [Competitor] = []

    /// カテゴリ別テリトリーポリゴン
    var territories: [Territory] = []

    /// 個別競合の影響圏
    var influenceZones: [InfluenceZone] = []

    /// マップカメラ位置
    var cameraPosition: MapCameraPosition = .automatic

    /// 検索中フラグ
    var isSearching = false

    /// 検索進捗メッセージ
    var searchProgressMessage = ""

    /// エラーメッセージ
    var errorMessage: String?

    /// 選択中の競合（詳細表示用）
    var selectedCompetitor: Competitor?

    /// コントロールパネル表示フラグ
    var showControlPanel = true

    /// テリトリー表示フラグ
    var showTerritories = true

    /// 影響圏表示フラグ
    var showInfluenceZones = false

    /// 距離圏表示フラグ
    var showDistanceRings = true

    /// 競合リスト表示フラグ
    var showCompetitorList = false

    /// 設定画面表示フラグ
    var showSettings = false

    // MARK: - Services

    private let searchService = CompetitorSearchService()
    private let territoryCalculator = TerritoryCalculator()

    // MARK: - Computed Properties

    /// カテゴリ別の競合数
    var competitorCountByCategory: [(category: SearchCategory, count: Int)] {
        let grouped = Dictionary(grouping: competitors, by: \.category)
        return SearchCategory.allCases.compactMap { category in
            guard let members = grouped[category], !members.isEmpty else { return nil }
            return (category: category, count: members.count)
        }
    }

    /// 全競合数
    var totalCompetitorCount: Int { competitors.count }

    /// 可視リング
    var visibleRings: [DistanceRing] {
        config.rings.filter(\.isVisible)
    }

    // MARK: - Actions

    /// 中心点を設定してカメラを移動
    func setCenter(_ coordinate: CLLocationCoordinate2D) {
        config.center = coordinate
        updateCamera()
    }

    /// カメラ位置を更新
    func updateCamera() {
        let span = spanForRadius(config.maxVisibleRingRadius * 1.3)
        cameraPosition = .region(
            MKCoordinateRegion(
                center: config.center,
                span: span
            )
        )
    }

    /// 選択カテゴリで周辺競合を検索
    func searchCompetitors() async {
        guard !config.selectedCategories.isEmpty else {
            errorMessage = "検索カテゴリを1つ以上選択してください"
            return
        }

        isSearching = true
        errorMessage = nil
        searchProgressMessage = "検索中..."

        do {
            let results = try await searchService.searchAll(
                categories: config.selectedCategories,
                center: config.center,
                radius: config.searchRadius
            )

            competitors = results
            recalculateTerritories()

            searchProgressMessage = "\(results.count)件の競合を検出"
        } catch {
            errorMessage = "検索エラー: \(error.localizedDescription)"
            searchProgressMessage = ""
        }

        isSearching = false
    }

    /// テリトリーと影響圏を再計算
    func recalculateTerritories() {
        territories = territoryCalculator.calculateTerritories(
            competitors: competitors,
            center: config.center,
            maxRadius: config.searchRadius
        )

        influenceZones = territoryCalculator.calculateInfluenceZones(
            competitors: competitors
        )
    }

    /// 距離圏リングを追加
    func addRing(radius: CLLocationDistance, color: Color) {
        let ring = DistanceRing(radius: radius, color: color)
        config.rings.append(ring)
        config.rings.sort { $0.radius < $1.radius }
        updateCamera()
    }

    /// 距離圏リングを削除
    func removeRing(_ ring: DistanceRing) {
        config.rings.removeAll { $0.id == ring.id }
    }

    /// リングの表示/非表示を切り替え
    func toggleRing(_ ring: DistanceRing) {
        if let index = config.rings.firstIndex(where: { $0.id == ring.id }) {
            config.rings[index].isVisible.toggle()
        }
    }

    /// カテゴリの選択/解除
    func toggleCategory(_ category: SearchCategory) {
        if config.selectedCategories.contains(category) {
            config.selectedCategories.remove(category)
        } else {
            config.selectedCategories.insert(category)
        }
    }

    /// 全データをクリア
    func clearResults() {
        competitors = []
        territories = []
        influenceZones = []
        searchProgressMessage = ""
        errorMessage = nil
        selectedCompetitor = nil
    }

    /// 検索半径を更新（最大リングに合わせる）
    func updateSearchRadius() {
        config.searchRadius = config.maxVisibleRingRadius
    }

    // MARK: - Private Helpers

    /// メートル単位の半径から適切なMKCoordinateSpanを計算
    private func spanForRadius(_ radiusMeters: CLLocationDistance) -> MKCoordinateSpan {
        let metersPerDegreeLatitude = 111_320.0
        let latDelta = radiusMeters / metersPerDegreeLatitude * 2
        let lonDelta = radiusMeters / (metersPerDegreeLatitude * cos(config.center.latitude * .pi / 180)) * 2
        return MKCoordinateSpan(
            latitudeDelta: latDelta,
            longitudeDelta: lonDelta
        )
    }
}
