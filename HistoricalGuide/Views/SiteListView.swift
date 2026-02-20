import SwiftUI

/// 史跡一覧リストビュー
struct SiteListView: View {
    @ObservedObject var viewModel: HistoricalSiteViewModel

    var body: some View {
        NavigationStack {
            List {
                // 検索バー
                if !viewModel.filteredSites.isEmpty {
                    // 時代ごとにグループ化して表示
                    ForEach(viewModel.sitesByEra, id: \.era) { group in
                        Section {
                            ForEach(group.sites) { site in
                                SiteListRow(site: site, viewModel: viewModel)
                                    .onTapGesture {
                                        viewModel.selectSite(site)
                                    }
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Text(group.era.rawValue)
                                    .font(.headline)
                                Text(group.era.yearRange)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "史跡が見つかりません",
                        systemImage: "magnifyingglass",
                        description: Text("検索条件を変更してください")
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("史跡一覧")
            .searchable(text: $viewModel.searchText, prompt: "史跡を検索...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        // 時代フィルタ
                        Menu("時代で絞り込み") {
                            Button("すべて") {
                                viewModel.selectedEraFilter = nil
                            }
                            ForEach(HistoricalEra.allCases) { era in
                                Button {
                                    viewModel.selectedEraFilter = era
                                } label: {
                                    HStack {
                                        Text(era.rawValue)
                                        if viewModel.selectedEraFilter == era {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }

                        // カテゴリフィルタ
                        Menu("カテゴリで絞り込み") {
                            Button("すべて") {
                                viewModel.selectedCategoryFilter = nil
                            }
                            ForEach(SiteCategory.allCases) { category in
                                Button {
                                    viewModel.selectedCategoryFilter = category
                                } label: {
                                    HStack {
                                        Image(systemName: category.iconName)
                                        Text(category.rawValue)
                                        if viewModel.selectedCategoryFilter == category {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }

                        Divider()

                        Button("フィルタをリセット") {
                            viewModel.clearFilters()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingDetail) {
            if let site = viewModel.selectedSite {
                SiteDetailView(site: site, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Site List Row

struct SiteListRow: View {
    let site: HistoricalSite
    @ObservedObject var viewModel: HistoricalSiteViewModel

    var body: some View {
        HStack(spacing: 12) {
            // カテゴリアイコン
            Image(systemName: site.category.iconName)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(eraColor, in: RoundedRectangle(cornerRadius: 10))

            // テキスト情報
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(site.name)
                        .font(.body)
                        .fontWeight(.semibold)

                    if viewModel.isFavorite(site) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Text(site.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    EraTag(era: site.era)

                    Text(site.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button {
                viewModel.toggleFavorite(for: site)
            } label: {
                Label(
                    viewModel.isFavorite(site) ? "解除" : "お気に入り",
                    systemImage: viewModel.isFavorite(site) ? "heart.slash" : "heart"
                )
            }
            .tint(viewModel.isFavorite(site) ? .gray : .red)
        }
    }

    private var eraColor: Color {
        switch site.era {
        case .jomon, .yayoi, .kofun: return .brown
        case .asuka, .nara: return .orange
        case .heian: return .purple
        case .kamakura, .muromachi: return .blue
        case .azuchiMomoyama: return .red
        case .edo: return .indigo
        case .meiji, .taisho, .showa: return .green
        }
    }
}
