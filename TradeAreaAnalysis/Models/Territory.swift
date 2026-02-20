import Foundation
import CoreLocation
import SwiftUI

/// 競合のテリトリー（勢力圏）を表すモデル
struct Territory: Identifiable {
    let id: UUID
    /// テリトリーの所有カテゴリ
    let category: SearchCategory
    /// テリトリーを構成するポリゴン頂点
    let polygon: [CLLocationCoordinate2D]
    /// テリトリーに含まれる競合数
    let competitorCount: Int

    init(
        id: UUID = UUID(),
        category: SearchCategory,
        polygon: [CLLocationCoordinate2D],
        competitorCount: Int
    ) {
        self.id = id
        self.category = category
        self.polygon = polygon
        self.competitorCount = competitorCount
    }

    var color: Color {
        category.color
    }
}

/// 個別競合の影響圏
struct InfluenceZone: Identifiable {
    let id: UUID
    let competitor: Competitor
    /// 影響圏の半径（最近接同業他社までの距離の半分）
    let radius: CLLocationDistance

    init(id: UUID = UUID(), competitor: Competitor, radius: CLLocationDistance) {
        self.id = id
        self.competitor = competitor
        self.radius = radius
    }
}
