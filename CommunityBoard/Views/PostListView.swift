import SwiftUI

/// 投稿一覧ビュー
struct PostListView: View {
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredPosts.isEmpty {
                    ContentUnavailableView(
                        "投稿が見つかりません",
                        systemImage: "map.fill",
                        description: Text("フィルター条件を変更するか、新しい投稿を作成してみましょう。")
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredPosts) { post in
                            postRow(post)
                                .onTapGesture {
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        viewModel.moveToPost(post)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("投稿一覧（\(viewModel.filteredPosts.count)件）")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func postRow(_ post: Post) -> some View {
        HStack(spacing: 12) {
            // カテゴリアイコン
            Image(systemName: post.category.icon)
                .font(.title2)
                .foregroundStyle(post.category.color)
                .frame(width: 44, height: 44)
                .background(post.category.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))

            // 投稿内容
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(post.title)
                        .font(.subheadline.bold())
                        .lineLimit(1)

                    if post.isResolved {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }

                Text(post.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    // 投稿者
                    HStack(spacing: 2) {
                        Text(post.authorEmoji)
                            .font(.caption2)
                        Text(post.authorName)
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)

                    // いいね
                    HStack(spacing: 2) {
                        Image(systemName: "heart")
                            .font(.system(size: 9))
                        Text("\(post.likeCount)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.pink)

                    // コメント
                    HStack(spacing: 2) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 9))
                        Text("\(post.commentCount)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)

                    Spacer()

                    // 時刻
                    Text(post.timeAgo)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
