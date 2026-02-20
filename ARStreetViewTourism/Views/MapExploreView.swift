import SwiftUI
import MapKit

/// マップ探索ビュー - Look Around統合
struct MapExploreView: View {
    @ObservedObject var viewModel: MapViewModel
    @State private var showLookAround = false
    @Namespace private var mapScope

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // メインマップ
                Map(position: $viewModel.cameraPosition, scope: mapScope) {
                    ForEach(viewModel.filteredSpots) { spot in
                        Annotation(
                            spot.nameJapanese,
                            coordinate: spot.coordinate,
                            anchor: .bottom
                        ) {
                            SpotAnnotationView(
                                spot: spot,
                                isSelected: viewModel.selectedSpot?.id == spot.id
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.selectSpot(spot)
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([
                    .museum, .nationalPark, .park, .temple, .castle
                ])))
                .mapControls {
                    MapCompass(scope: mapScope)
                    MapScaleView(scope: mapScope)
                    MapUserLocationButton(scope: mapScope)
                }
                .mapScope(mapScope)

                // 選択中スポットの情報カード
                if let spot = viewModel.selectedSpot {
                    SpotInfoCard(
                        spot: spot,
                        isLoadingLookAround: viewModel.isLoadingLookAround,
                        lookAroundAvailable: viewModel.lookAroundAvailable,
                        onLookAroundTap: { showLookAround = true },
                        onDismiss: {
                            withAnimation {
                                viewModel.selectedSpot = nil
                                viewModel.lookAroundScene = nil
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("AR観光ガイド")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AreaPickerMenu(viewModel: viewModel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CategoryFilterMenu(viewModel: viewModel)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "スポットを検索")
            .sheet(isPresented: $showLookAround) {
                if let scene = viewModel.lookAroundScene, let spot = viewModel.selectedSpot {
                    LookAroundExperienceView(scene: scene, spot: spot)
                }
            }
        }
    }
}

// MARK: - スポットアノテーションビュー

struct SpotAnnotationView: View {
    let spot: TouristSpot
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(categoryColor.gradient)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: categoryColor.opacity(0.4), radius: isSelected ? 8 : 4)

                Image(systemName: spot.category.systemImage)
                    .font(isSelected ? .body : .caption)
                    .foregroundStyle(.white)
            }

            // 三角形の尾
            Triangle()
                .fill(categoryColor.gradient)
                .frame(width: 12, height: 8)
        }
        .animation(.spring(response: 0.3), value: isSelected)
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

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - スポット情報カード

struct SpotInfoCard: View {
    let spot: TouristSpot
    let isLoadingLookAround: Bool
    let lookAroundAvailable: Bool
    let onLookAroundTap: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.nameJapanese)
                        .font(.headline)
                    Text(spot.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Text(spot.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 12) {
                // Look Aroundボタン
                Button(action: onLookAroundTap) {
                    HStack(spacing: 6) {
                        if isLoadingLookAround {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "binoculars.fill")
                        }
                        Text("Look Around")
                            .font(.subheadline.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(lookAroundAvailable ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundStyle(lookAroundAvailable ? .white : .secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!lookAroundAvailable || isLoadingLookAround)

                // カテゴリバッジ
                Label(spot.category.rawValue, systemImage: spot.category.systemImage)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - エリア選択メニュー

struct AreaPickerMenu: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        Menu {
            ForEach(MapViewModel.AreaPreset.allCases, id: \.self) { area in
                Button(action: { viewModel.moveToArea(area) }) {
                    Label(area.rawValue, systemImage: "mappin.and.ellipse")
                }
            }
        } label: {
            Image(systemName: "globe.asia.australia")
        }
    }
}

// MARK: - カテゴリフィルターメニュー

struct CategoryFilterMenu: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        Menu {
            Button("すべて表示") {
                viewModel.selectedCategory = nil
            }
            Divider()
            ForEach(TouristSpot.Category.allCases, id: \.self) { category in
                Button(action: { viewModel.selectedCategory = category }) {
                    Label(category.rawValue, systemImage: category.systemImage)
                }
            }
        } label: {
            Image(systemName: viewModel.selectedCategory == nil
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
    }
}

#Preview {
    MapExploreView(viewModel: MapViewModel())
}
