import SwiftUI

/// 検索カテゴリ - 周辺競合を検出する際の業種分類
enum SearchCategory: String, CaseIterable, Identifiable, Codable {
    case restaurant = "レストラン"
    case cafe = "カフェ"
    case convenience = "コンビニ"
    case supermarket = "スーパー"
    case retail = "小売店"
    case drugstore = "ドラッグストア"
    case gym = "ジム"
    case beauty = "美容院"

    var id: String { rawValue }

    /// MKLocalSearch用の英語クエリ
    var searchQuery: String {
        switch self {
        case .restaurant: return "restaurant"
        case .cafe: return "cafe coffee"
        case .convenience: return "convenience store"
        case .supermarket: return "supermarket grocery"
        case .retail: return "retail shop"
        case .drugstore: return "drugstore pharmacy"
        case .gym: return "gym fitness"
        case .beauty: return "beauty salon hair"
        }
    }

    /// SF Symbolsアイコン名
    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .convenience: return "building.2.fill"
        case .supermarket: return "cart.fill"
        case .retail: return "bag.fill"
        case .drugstore: return "cross.case.fill"
        case .gym: return "figure.run"
        case .beauty: return "scissors"
        }
    }

    /// カテゴリ別のテーマカラー
    var color: Color {
        switch self {
        case .restaurant: return .red
        case .cafe: return .brown
        case .convenience: return .blue
        case .supermarket: return .green
        case .retail: return .purple
        case .drugstore: return .mint
        case .gym: return .orange
        case .beauty: return .pink
        }
    }
}
