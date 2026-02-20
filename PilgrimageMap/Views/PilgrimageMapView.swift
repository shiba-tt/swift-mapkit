import SwiftUI
import MapKit

/// 聖地巡礼スポットをAnnotationで表示するマップビュー
struct PilgrimageMapView: View {
    @Environment(PilgrimageSpotStore.self) private var store
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        )
    )
    @State private var selectedSpot: PilgrimageSpot?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition, selection: $selectedSpot) {
                    ForEach(store.filteredSpots) { spot in
                        Annotation(spot.name, coordinate: spot.coordinate, anchor: .bottom) {
                            SpotAnnotationView(
                                spot: spot,
                                isCheckedIn: store.hasCheckedIn(spot: spot)
                            )
                        }
                        .tag(spot)
                    }

                    UserAnnotation()
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }

                if let selectedSpot {
                    SpotPreviewCard(spot: selectedSpot, store: store) {
                        showDetail = true
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedSpot)
            .navigationTitle("聖地巡礼マップ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    categoryFilterMenu
                }
            }
            .navigationDestination(isPresented: $showDetail) {
                if let selectedSpot {
                    SpotDetailView(spot: selectedSpot)
                }
            }
            .onChange(of: selectedSpot) { _, newValue in
                if let spot = newValue {
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: spot.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        )
                    }
                }
            }
        }
    }

    private var categoryFilterMenu: some View {
        Menu {
            Button {
                store.selectedCategory = nil
            } label: {
                Label("すべて表示", systemImage: "list.bullet")
            }

            Divider()

            ForEach(PilgrimageSpot.Category.allCases) { category in
                Button {
                    store.selectedCategory = category
                } label: {
                    Label(category.rawValue, systemImage: category.icon)
                }
            }
        } label: {
            Image(systemName: store.selectedCategory == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
    }
}

// MARK: - Annotation View

struct SpotAnnotationView: View {
    let spot: PilgrimageSpot
    let isCheckedIn: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(annotationColor)
                    .frame(width: 36, height: 36)

                Image(systemName: spot.category.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)

                if isCheckedIn {
                    Circle()
                        .fill(.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .offset(x: 14, y: -14)
                }
            }

            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundStyle(annotationColor)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
        }
    }

    private var annotationColor: Color {
        switch spot.category {
        case .anime: return .purple
        case .movie: return .red
        case .drama: return .blue
        case .game: return .green
        }
    }
}

// MARK: - Preview Card

struct SpotPreviewCard: View {
    let spot: PilgrimageSpot
    let store: PilgrimageSpotStore
    let onDetailTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: spot.category.icon)
                            .font(.caption)
                            .foregroundStyle(categoryColor)
                        Text(spot.workTitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(spot.name)
                        .font(.headline)

                    Text(spot.sceneName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if store.hasCheckedIn(spot: spot) {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                            .font(.title2)
                        Text("訪問済み")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }

            Button(action: onDetailTap) {
                HStack {
                    Text("詳細を見る")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.tint.opacity(0.1))
                .foregroundStyle(.tint)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
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
    PilgrimageMapView()
        .environment(PilgrimageSpotStore())
}
