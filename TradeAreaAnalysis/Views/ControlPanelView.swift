import SwiftUI

/// マップ上のコントロールパネル（検索・表示切替）
struct ControlPanelView: View {
    @Bindable var viewModel: TradeAreaViewModel

    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            headerSection

            if viewModel.showControlPanel {
                Divider()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // カテゴリ選択
                        categorySection

                        Divider()

                        // 表示オプション
                        displayOptionsSection

                        Divider()

                        // 検索ボタン
                        searchSection
                    }
                    .padding(12)
                }
                .frame(maxHeight: 320)
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
    }

    // MARK: - ヘッダー

    private var headerSection: some View {
        HStack {
            Image(systemName: "map.circle.fill")
                .font(.title3)
                .foregroundStyle(.blue)

            Text("商圏分析")
                .font(.headline)

            Spacer()

            if viewModel.totalCompetitorCount > 0 {
                Text("\(viewModel.totalCompetitorCount)件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
            }

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.showControlPanel.toggle()
                }
            } label: {
                Image(systemName: viewModel.showControlPanel ? "chevron.up" : "chevron.down")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
    }

    // MARK: - カテゴリ選択

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("検索カテゴリ")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ],
                spacing: 8
            ) {
                ForEach(SearchCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: viewModel.config.selectedCategories.contains(category),
                        count: viewModel.competitors.filter { $0.category == category }.count
                    ) {
                        viewModel.toggleCategory(category)
                    }
                }
            }
        }
    }

    // MARK: - 表示オプション

    private var displayOptionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("表示オプション")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)

            Toggle(isOn: $viewModel.showDistanceRings) {
                Label("距離圏", systemImage: "circle.dashed")
                    .font(.subheadline)
            }
            .toggleStyle(.switch)
            .tint(.blue)

            Toggle(isOn: $viewModel.showTerritories) {
                Label("テリトリー", systemImage: "hexagon.fill")
                    .font(.subheadline)
            }
            .toggleStyle(.switch)
            .tint(.purple)

            Toggle(isOn: $viewModel.showInfluenceZones) {
                Label("影響圏", systemImage: "circle.hexagongrid.fill")
                    .font(.subheadline)
            }
            .toggleStyle(.switch)
            .tint(.orange)
        }
    }

    // MARK: - 検索セクション

    private var searchSection: some View {
        VStack(spacing: 8) {
            Button {
                Task { await viewModel.searchCompetitors() }
            } label: {
                HStack {
                    if viewModel.isSearching {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                    Text(viewModel.isSearching ? "検索中..." : "競合を検索")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSearching || viewModel.config.selectedCategories.isEmpty)

            if !viewModel.searchProgressMessage.isEmpty {
                Text(viewModel.searchProgressMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

/// カテゴリ選択チップ
struct CategoryChip: View {
    let category: SearchCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .lineLimit(1)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 4)
                        .background(.white.opacity(0.3), in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(
                isSelected ? category.color.opacity(0.2) : Color.gray.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 8)
            )
            .foregroundStyle(isSelected ? category.color : .secondary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? category.color : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
