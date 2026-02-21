import SwiftUI

/// スポット一覧ビュー - 作品別・カテゴリ別にブラウズ
struct SpotListView: View {
    @Environment(PilgrimageSpotStore.self) private var store
    @State private var searchText = ""
    @State private var selectedCategory: PilgrimageSpot.Category?

    private var groupedSpots: [(String, [PilgrimageSpot])] {
        let filtered = store.spots.filter { spot in
            let matchesSearch = searchText.isEmpty ||
                spot.name.localizedCaseInsensitiveContains(searchText) ||
                spot.workTitle.localizedCaseInsensitiveContains(searchText) ||
                spot.sceneName.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || spot.category == selectedCategory
            return matchesSearch && matchesCategory
        }

        let grouped = Dictionary(grouping: filtered) { $0.workTitle }
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                // カテゴリフィルター
                categoryFilterSection

                // スポット一覧
                if groupedSpots.isEmpty {
                    ContentUnavailableView(
                        "スポットが見つかりません",
                        systemImage: "mappin.slash",
                        description: Text("検索条件を変更してください")
                    )
                } else {
                    ForEach(groupedSpots, id: \.0) { workTitle, spots in
                        Section {
                            ForEach(spots) { spot in
                                NavigationLink(value: spot) {
                                    SpotRowView(spot: spot, isCheckedIn: store.hasCheckedIn(spot: spot))
                                }
                            }
                        } header: {
                            Text(workTitle)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "スポット名・作品名で検索")
            .navigationTitle("スポット一覧")
            .navigationDestination(for: PilgrimageSpot.self) { spot in
                SpotDetailView(spot: spot)
            }
        }
    }

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(
                    title: "すべて",
                    icon: "list.bullet",
                    isSelected: selectedCategory == nil,
                    color: .primary
                ) {
                    selectedCategory = nil
                }

                ForEach(PilgrimageSpot.Category.allCases) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        color: chipColor(for: category)
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }

    private func chipColor(for category: PilgrimageSpot.Category) -> Color {
        switch category {
        case .anime: return .purple
        case .movie: return .red
        case .drama: return .blue
        case .game: return .green
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color(.systemGray6))
                .foregroundStyle(isSelected ? color : .secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? color.opacity(0.5) : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Spot Row

struct SpotRowView: View {
    let spot: PilgrimageSpot
    let isCheckedIn: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: spot.category.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.body.weight(.medium))

                Text(spot.sceneName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isCheckedIn {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 2)
    }

    private var categoryColor: Color {
        switch spot.category {
        case .anime: return .purple
        case .movie: return .red
        case .drama: return .blue
        case .game: return .green
        }
    }
}

#Preview {
    SpotListView()
        .environment(PilgrimageSpotStore())
}
