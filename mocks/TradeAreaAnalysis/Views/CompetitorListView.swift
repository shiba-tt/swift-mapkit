import SwiftUI

/// 検出された競合店舗の一覧ビュー
struct CompetitorListView: View {
    @Bindable var viewModel: TradeAreaViewModel

    @State private var filterCategory: SearchCategory?
    @State private var sortOrder: SortOrder = .distance

    enum SortOrder: String, CaseIterable {
        case distance = "距離順"
        case name = "名前順"
        case category = "カテゴリ順"
    }

    var filteredCompetitors: [Competitor] {
        var result = viewModel.competitors

        if let filter = filterCategory {
            result = result.filter { $0.category == filter }
        }

        switch sortOrder {
        case .distance:
            result.sort { $0.distance < $1.distance }
        case .name:
            result.sort { $0.name < $1.name }
        case .category:
            result.sort {
                if $0.category.rawValue != $1.category.rawValue {
                    return $0.category.rawValue < $1.category.rawValue
                }
                return $0.distance < $1.distance
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 統計サマリー
                summaryHeader

                Divider()

                // フィルター・ソート
                filterBar

                Divider()

                // 競合リスト
                if filteredCompetitors.isEmpty {
                    emptyState
                } else {
                    competitorList
                }
            }
            .navigationTitle("競合一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        viewModel.showCompetitorList = false
                    }
                }
            }
        }
    }

    // MARK: - サマリーヘッダー

    private var summaryHeader: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatBadge(
                    label: "合計",
                    value: "\(viewModel.totalCompetitorCount)",
                    color: .blue
                )

                ForEach(viewModel.competitorCountByCategory, id: \.category) { item in
                    StatBadge(
                        label: item.category.rawValue,
                        value: "\(item.count)",
                        color: item.category.color
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - フィルターバー

    private var filterBar: some View {
        HStack {
            // カテゴリフィルター
            Menu {
                Button("すべて") { filterCategory = nil }
                ForEach(SearchCategory.allCases) { category in
                    Button {
                        filterCategory = category
                    } label: {
                        Label(category.rawValue, systemImage: category.icon)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(filterCategory?.rawValue ?? "すべて")
                        .font(.subheadline)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.gray.opacity(0.1), in: Capsule())
            }

            Spacer()

            // ソート
            Picker("並び替え", selection: $sortOrder) {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 240)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - 競合リスト

    private var competitorList: some View {
        List(filteredCompetitors) { competitor in
            CompetitorRow(competitor: competitor)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedCompetitor = competitor
                }
        }
        .listStyle(.plain)
    }

    // MARK: - 空状態

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("競合が見つかりません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("検索カテゴリを変更するか\n検索範囲を広げてください")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

/// 競合リストの行コンポーネント
struct CompetitorRow: View {
    let competitor: Competitor

    var body: some View {
        HStack(spacing: 12) {
            // カテゴリアイコン
            ZStack {
                Circle()
                    .fill(competitor.category.color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: competitor.category.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(competitor.category.color)
            }

            // 店舗情報
            VStack(alignment: .leading, spacing: 2) {
                Text(competitor.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Text(competitor.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // 距離
            VStack(alignment: .trailing, spacing: 2) {
                Text(competitor.formattedDistance)
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)

                Text(competitor.category.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// 統計バッジ
struct StatBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 50)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}
