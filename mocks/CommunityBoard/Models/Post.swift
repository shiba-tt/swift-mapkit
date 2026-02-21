import Foundation
import CoreLocation

/// コミュニティ掲示板の投稿
struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var category: PostCategory
    var latitude: Double
    var longitude: Double
    var authorId: UUID
    var authorName: String
    var authorEmoji: String
    var createdAt: Date
    var expiresAt: Date?
    var likeCount: Int
    var commentCount: Int
    var isResolved: Bool
    var tags: [String]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var isExpired: Bool {
        if let expiresAt {
            return Date() > expiresAt
        }
        return false
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        category: PostCategory,
        latitude: Double,
        longitude: Double,
        authorId: UUID,
        authorName: String,
        authorEmoji: String = "😊",
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        likeCount: Int = 0,
        commentCount: Int = 0,
        isResolved: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.authorId = authorId
        self.authorName = authorName
        self.authorEmoji = authorEmoji
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isResolved = isResolved
        self.tags = tags
    }
}
