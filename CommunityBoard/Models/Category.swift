import SwiftUI

/// 投稿のカテゴリ
enum PostCategory: String, CaseIterable, Identifiable, Codable {
    case info = "情報共有"
    case help = "助け合い"
    case event = "イベント"
    case rumor = "噂・口コミ"
    case lostFound = "落とし物"
    case safety = "安全・防犯"
    case food = "グルメ"
    case nature = "自然・散歩"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .help: return "hand.raised.fill"
        case .event: return "calendar.circle.fill"
        case .rumor: return "bubble.left.and.bubble.right.fill"
        case .lostFound: return "magnifyingglass.circle.fill"
        case .safety: return "shield.checkered"
        case .food: return "fork.knife.circle.fill"
        case .nature: return "leaf.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .info: return .blue
        case .help: return .orange
        case .event: return .purple
        case .rumor: return .pink
        case .lostFound: return .yellow
        case .safety: return .red
        case .food: return .green
        case .nature: return .teal
        }
    }

    var description: String {
        switch self {
        case .info: return "地域の情報を共有しましょう"
        case .help: return "困っていることや手伝えることを投稿"
        case .event: return "地域のイベント情報"
        case .rumor: return "近所の噂やお店の口コミ"
        case .lostFound: return "落とし物・忘れ物の情報"
        case .safety: return "防犯・安全に関する情報"
        case .food: return "おすすめの飲食店やグルメ情報"
        case .nature: return "自然スポットやお散歩コース"
        }
    }
}
