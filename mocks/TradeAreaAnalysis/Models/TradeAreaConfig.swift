import Foundation
import CoreLocation
import SwiftUI

/// 距離圏リング（同心円）の設定
struct DistanceRing: Identifiable, Equatable {
    let id: UUID
    var radius: CLLocationDistance
    var color: Color
    var label: String
    var isVisible: Bool

    init(
        id: UUID = UUID(),
        radius: CLLocationDistance,
        color: Color,
        label: String? = nil,
        isVisible: Bool = true
    ) {
        self.id = id
        self.radius = radius
        self.color = color
        self.label = label ?? Self.formatRadius(radius)
        self.isVisible = isVisible
    }

    var formattedRadius: String {
        Self.formatRadius(radius)
    }

    private static func formatRadius(_ radius: CLLocationDistance) -> String {
        if radius >= 1000 {
            return String(format: "%.1f km", radius / 1000)
        }
        return String(format: "%.0f m", radius)
    }
}

/// 商圏分析の全体設定
struct TradeAreaConfig {
    /// 分析の中心座標
    var center: CLLocationCoordinate2D
    /// 距離圏リングの配列
    var rings: [DistanceRing]
    /// 最大検索半径（メートル）
    var searchRadius: CLLocationDistance
    /// 検索対象カテゴリ
    var selectedCategories: Set<SearchCategory>

    /// デフォルト設定（東京駅中心）
    static var `default`: TradeAreaConfig {
        TradeAreaConfig(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            rings: [
                DistanceRing(radius: 500, color: .green.opacity(0.8)),
                DistanceRing(radius: 1000, color: .yellow.opacity(0.8)),
                DistanceRing(radius: 3000, color: .orange.opacity(0.8)),
                DistanceRing(radius: 5000, color: .red.opacity(0.8), isVisible: false),
            ],
            searchRadius: 3000,
            selectedCategories: [.restaurant, .cafe, .convenience]
        )
    }

    /// 最大の可視リングの半径
    var maxVisibleRingRadius: CLLocationDistance {
        rings.filter(\.isVisible).map(\.radius).max() ?? searchRadius
    }
}
