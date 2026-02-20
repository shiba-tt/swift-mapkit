import Foundation

/// 投稿へのコメント
struct Comment: Identifiable, Codable, Hashable {
    let id: UUID
    var postId: UUID
    var authorId: UUID
    var authorName: String
    var authorEmoji: String
    var body: String
    var createdAt: Date
    var likeCount: Int

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    init(
        id: UUID = UUID(),
        postId: UUID,
        authorId: UUID,
        authorName: String,
        authorEmoji: String = "😊",
        body: String,
        createdAt: Date = Date(),
        likeCount: Int = 0
    ) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.authorName = authorName
        self.authorEmoji = authorEmoji
        self.body = body
        self.createdAt = createdAt
        self.likeCount = likeCount
    }
}
