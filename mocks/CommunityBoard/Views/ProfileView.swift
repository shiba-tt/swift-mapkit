import SwiftUI

/// プロフィール・ユーザー情報ビュー
struct ProfileView: View {
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss

    private let emojiOptions = ["🙂", "😊", "😎", "🤓", "👨", "👩", "🧑", "👧", "👴", "👶", "🐱", "🐶"]

    var body: some View {
        NavigationStack {
            Form {
                // プロフィールヘッダー
                Section {
                    VStack(spacing: 12) {
                        Text(viewModel.currentUser.avatarEmoji)
                            .font(.system(size: 60))
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.1), in: Circle())

                        Text(viewModel.currentUser.name)
                            .font(.title2.bold())

                        HStack(spacing: 4) {
                            Image(systemName: viewModel.currentUser.level.icon)
                            Text(viewModel.currentUser.level.rawValue)
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.accent.opacity(0.1), in: Capsule())
                        .foregroundStyle(.accent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                // 統計
                Section("アクティビティ") {
                    HStack {
                        statItem(value: viewModel.currentUser.postCount, label: "投稿", icon: "square.and.pencil")
                        Divider()
                        statItem(value: viewModel.currentUser.helpCount, label: "お手伝い", icon: "hand.raised.fill")
                        Divider()
                        statItem(value: viewModel.currentUser.reputation, label: "評判", icon: "star.fill")
                    }
                    .padding(.vertical, 4)
                }

                // アバター変更
                Section("アバターを変更") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .background(
                                    viewModel.currentUser.avatarEmoji == emoji
                                        ? Color.accent.opacity(0.2)
                                        : Color.gray.opacity(0.05),
                                    in: Circle()
                                )
                                .overlay(
                                    Circle().stroke(
                                        viewModel.currentUser.avatarEmoji == emoji
                                            ? Color.accent
                                            : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                                .onTapGesture {
                                    viewModel.currentUser.avatarEmoji = emoji
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 名前変更
                Section("名前を変更") {
                    TextField("名前", text: $viewModel.currentUser.name)
                }

                // 自己紹介
                Section("自己紹介") {
                    TextField("自己紹介を入力...", text: $viewModel.currentUser.bio, axis: .vertical)
                        .lineLimit(2...4)
                }

                // 自分の投稿
                Section("あなたの投稿（\(myPosts.count)件）") {
                    if myPosts.isEmpty {
                        Text("まだ投稿がありません")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(myPosts) { post in
                            HStack {
                                Image(systemName: post.category.icon)
                                    .foregroundStyle(post.category.color)
                                VStack(alignment: .leading) {
                                    Text(post.title)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    Text(post.timeAgo)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }

    private var myPosts: [Post] {
        viewModel.posts.filter { $0.authorId == viewModel.currentUser.id }
    }

    private func statItem(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.accent)
            Text("\(value)")
                .font(.title3.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
