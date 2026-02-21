import SwiftUI

/// 投稿詳細ビュー
struct PostDetailView: View {
    @ObservedObject var viewModel: MapViewModel
    let post: Post
    @State private var commentText = ""
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // ヘッダー
                    postHeader

                    Divider()

                    // 本文
                    Text(post.body)
                        .font(.body)
                        .lineSpacing(4)

                    // タグ
                    if !post.tags.isEmpty {
                        tagsSection
                    }

                    // アクション
                    actionButtons

                    Divider()

                    // コメントセクション
                    commentsSection

                    // コメント入力
                    commentInput
                }
                .padding()
            }
            .navigationTitle("投稿詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .alert("投稿を削除しますか？", isPresented: $showDeleteConfirm) {
                Button("削除", role: .destructive) {
                    viewModel.deletePost(post)
                    dismiss()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("この操作は取り消せません。")
            }
        }
    }

    // MARK: - Post Header

    private var postHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            // カテゴリ・ステータスバッジ
            HStack {
                Label(post.category.rawValue, systemImage: post.category.icon)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(post.category.color.opacity(0.15), in: Capsule())
                    .foregroundStyle(post.category.color)

                if post.isResolved {
                    Label("解決済み", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.15), in: Capsule())
                        .foregroundStyle(.green)
                }

                Spacer()

                Text(post.timeAgo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // タイトル
            Text(post.title)
                .font(.title2.bold())

            // 投稿者情報
            HStack(spacing: 8) {
                Text(post.authorEmoji)
                    .font(.title3)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.1), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.subheadline.bold())
                    Text("投稿者")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Tags

    private var tagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(post.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1), in: Capsule())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // いいね
            Button {
                viewModel.likePost(post)
            } label: {
                Label("\(post.likeCount)", systemImage: "heart")
                    .font(.subheadline)
            }
            .tint(.pink)

            // コメント数
            Label("\(post.commentCount)", systemImage: "bubble.right")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            // 解決ボタン（助け合い・落とし物カテゴリ）
            if (post.category == .help || post.category == .lostFound) && !post.isResolved {
                Button {
                    viewModel.resolvePost(post)
                } label: {
                    Label("解決済みにする", systemImage: "checkmark.circle")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.green.opacity(0.15), in: Capsule())
                }
                .tint(.green)
            }

            // 削除（自分の投稿のみ）
            if post.authorId == viewModel.currentUser.id {
                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.subheadline)
                }
                .tint(.red)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Comments

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("コメント")
                .font(.headline)

            let postComments = viewModel.commentsForPost(post)

            if postComments.isEmpty {
                Text("まだコメントはありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(postComments) { comment in
                    commentRow(comment)
                }
            }
        }
    }

    private func commentRow(_ comment: Comment) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(comment.authorEmoji)
                .font(.callout)
                .frame(width: 28, height: 28)
                .background(Color.gray.opacity(0.1), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorName)
                        .font(.caption.bold())
                    Text(comment.timeAgo)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(comment.body)
                    .font(.subheadline)

                if comment.likeCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 9))
                        Text("\(comment.likeCount)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.pink)
                }
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Comment Input

    private var commentInput: some View {
        HStack(spacing: 8) {
            Text(viewModel.currentUser.avatarEmoji)
                .frame(width: 30, height: 30)
                .background(Color.gray.opacity(0.1), in: Circle())

            TextField("コメントを入力...", text: $commentText)
                .textFieldStyle(.roundedBorder)

            Button {
                guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                viewModel.addComment(to: post, body: commentText)
                commentText = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(commentText.isEmpty ? .secondary : .accent)
            }
            .disabled(commentText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}
