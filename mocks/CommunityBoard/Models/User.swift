import Foundation

/// コミュニティユーザー
struct CommunityUser: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var avatarEmoji: String
    var bio: String
    var joinDate: Date
    var postCount: Int
    var helpCount: Int
    var reputation: Int

    var level: UserLevel {
        switch reputation {
        case 0..<10: return .newcomer
        case 10..<50: return .regular
        case 50..<100: return .contributor
        case 100..<200: return .trusted
        default: return .leader
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        avatarEmoji: String = "😊",
        bio: String = "",
        joinDate: Date = Date(),
        postCount: Int = 0,
        helpCount: Int = 0,
        reputation: Int = 0
    ) {
        self.id = id
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.bio = bio
        self.joinDate = joinDate
        self.postCount = postCount
        self.helpCount = helpCount
        self.reputation = reputation
    }
}

/// ユーザーレベル
enum UserLevel: String, Codable {
    case newcomer = "ニューカマー"
    case regular = "レギュラー"
    case contributor = "コントリビューター"
    case trusted = "信頼メンバー"
    case leader = "リーダー"

    var icon: String {
        switch self {
        case .newcomer: return "star"
        case .regular: return "star.leadinghalf.filled"
        case .contributor: return "star.fill"
        case .trusted: return "star.circle.fill"
        case .leader: return "crown.fill"
        }
    }
}
