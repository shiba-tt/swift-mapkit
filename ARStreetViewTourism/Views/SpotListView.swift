import SwiftUI

/// 観光スポット一覧ビュー
struct SpotListView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        NavigationStack {
            List {
                // カテゴリフィルターセクション
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryChip(
                                title: "すべて",
                                systemImage: "square.grid.2x2",
                                isSelected: viewModel.selectedCategory == nil,
                                color: .primary
                            ) {
                                viewModel.selectedCategory = nil
                            }

                            ForEach(TouristSpot.Category.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    systemImage: category.systemImage,
                                    isSelected: viewModel.selectedCategory == category,
                                    color: colorForCategory(category)
                                ) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                // スポットリスト
                Section {
                    ForEach(viewModel.filteredSpots) { spot in
                        NavigationLink(destination: SpotDetailView(spot: spot, viewModel: viewModel)) {
                            SpotRowView(spot: spot)
                        }
                    }
                } header: {
                    Text("\(viewModel.filteredSpots.count)件のスポット")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("観光スポット")
            .searchable(text: $viewModel.searchText, prompt: "名前・説明で検索")
        }
    }

    private func colorForCategory(_ category: TouristSpot.Category) -> Color {
        switch category {
        case .temple: return .orange
        case .shrine: return .red
        case .landmark: return .purple
        case .nature: return .green
        case .modern: return .blue
        }
    }
}

// MARK: - カテゴリチップ

struct CategoryChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.caption2)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.15) : Color.secondary.opacity(0.08))
            .foregroundStyle(isSelected ? color : .secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - スポット行ビュー

struct SpotRowView: View {
    let spot: TouristSpot
    @State private var lookAroundAvailable: Bool?

    var body: some View {
        HStack(spacing: 12) {
            // カテゴリアイコン
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: spot.category.systemImage)
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.nameJapanese)
                    .font(.headline)

                Text(spot.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Label(spot.category.rawValue, systemImage: spot.category.systemImage)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if let available = lookAroundAvailable {
                        HStack(spacing: 2) {
                            Image(systemName: "binoculars")
                            Text(available ? "360\u{00B0}" : "N/A")
                        }
                        .font(.caption2)
                        .foregroundStyle(available ? .blue : .secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .task {
            await checkLookAround()
        }
    }

    private func checkLookAround() async {
        let request = MKLookAroundSceneRequest(coordinate: spot.coordinate)
        do {
            let scene = try await request.scene
            lookAroundAvailable = scene != nil
        } catch {
            lookAroundAvailable = false
        }
    }

    private var categoryColor: Color {
        switch spot.category {
        case .temple: return .orange
        case .shrine: return .red
        case .landmark: return .purple
        case .nature: return .green
        case .modern: return .blue
        }
    }
}

#Preview {
    SpotListView(viewModel: MapViewModel())
}
