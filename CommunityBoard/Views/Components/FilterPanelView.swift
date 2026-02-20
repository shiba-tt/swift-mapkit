import SwiftUI

/// フィルターパネルビュー
struct FilterPanelView: View {
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // カテゴリフィルター
                Section("カテゴリ") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(PostCategory.allCases) { category in
                            categoryToggle(category)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Button("すべて選択") {
                            viewModel.selectedCategories = Set(PostCategory.allCases)
                        }
                        .font(.caption)
                        Spacer()
                        Button("すべて解除") {
                            viewModel.selectedCategories.removeAll()
                        }
                        .font(.caption)
                    }
                }

                // ソート
                Section("並び替え") {
                    Picker("並び順", selection: $viewModel.sortOrder) {
                        ForEach(MapViewModel.SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 表示オプション
                Section("表示オプション") {
                    Toggle("解決済みの投稿を表示", isOn: $viewModel.showResolvedPosts)
                }

                // 統計
                Section("統計") {
                    HStack {
                        Text("表示中の投稿")
                        Spacer()
                        Text("\(viewModel.filteredPosts.count)件")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("全投稿数")
                        Spacer()
                        Text("\(viewModel.totalActivePosts)件")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("フィルター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }

    private func categoryToggle(_ category: PostCategory) -> some View {
        let isSelected = viewModel.selectedCategories.contains(category)
        return Button {
            withAnimation {
                if isSelected {
                    viewModel.selectedCategories.remove(category)
                } else {
                    viewModel.selectedCategories.insert(category)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected ? category.color.opacity(0.15) : Color.gray.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 8)
            )
            .foregroundStyle(isSelected ? category.color : .secondary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? category.color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
