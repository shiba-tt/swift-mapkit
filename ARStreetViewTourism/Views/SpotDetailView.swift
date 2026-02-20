import SwiftUI
import MapKit

/// 観光スポット詳細ビュー
struct SpotDetailView: View {
    let spot: TouristSpot
    @ObservedObject var viewModel: MapViewModel
    @State private var showLookAround = false
    @State private var localLookAroundScene: MKLookAroundScene?
    @State private var isLoadingScene = false
    @State private var lookAroundReady = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // ミニマップ
                miniMapSection

                // スポット情報
                spotInfoSection

                // Look Aroundプレビュー
                lookAroundSection

                // アクションボタン
                actionButtons
            }
            .padding()
        }
        .navigationTitle(spot.nameJapanese)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadLookAroundScene()
        }
        .sheet(isPresented: $showLookAround) {
            if let scene = localLookAroundScene {
                LookAroundExperienceView(scene: scene, spot: spot)
            }
        }
    }

    // MARK: - ミニマップセクション

    private var miniMapSection: some View {
        Map {
            Annotation(
                spot.nameJapanese,
                coordinate: spot.coordinate,
                anchor: .bottom
            ) {
                SpotAnnotationView(spot: spot, isSelected: true)
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .allowsHitTesting(false)
    }

    // MARK: - スポット情報セクション

    private var spotInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(spot.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Label(spot.category.rawValue, systemImage: spot.category.systemImage)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(categoryColor.opacity(0.15))
                    .foregroundStyle(categoryColor)
                    .clipShape(Capsule())
            }

            Text(spot.description)
                .font(.body)
                .lineSpacing(4)

            // 座標情報
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(.blue)
                Text(String(format: "%.4f\u{00B0}N, %.4f\u{00B0}E",
                            spot.coordinate.latitude,
                            spot.coordinate.longitude))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Look Aroundセクション

    private var lookAroundSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Look Around", systemImage: "binoculars.fill")
                    .font(.headline)
                Spacer()
                if lookAroundReady {
                    Text("利用可能")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            LookAroundMiniPreview(scene: localLookAroundScene, isLoading: isLoadingScene)

            if lookAroundReady {
                Text("タップして360\u{00B0}ストリートビューを体験")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onTapGesture {
            if lookAroundReady {
                showLookAround = true
            }
        }
    }

    // MARK: - アクションボタン

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Look Around フルスクリーンボタン
            Button {
                showLookAround = true
            } label: {
                HStack {
                    Image(systemName: "binoculars.fill")
                    Text("360\u{00B0} ストリートビューを開く")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(lookAroundReady ? Color.blue : Color.gray.opacity(0.3))
                .foregroundStyle(lookAroundReady ? .white : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!lookAroundReady)

            // マップで開くボタン
            Button {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: spot.coordinate))
                mapItem.name = spot.nameJapanese
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue
                ])
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Apple マップで開く")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.secondary.opacity(0.1))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - ヘルパー

    private func loadLookAroundScene() async {
        isLoadingScene = true
        let request = MKLookAroundSceneRequest(coordinate: spot.coordinate)
        do {
            let scene = try await request.scene
            localLookAroundScene = scene
            lookAroundReady = scene != nil
        } catch {
            lookAroundReady = false
        }
        isLoadingScene = false
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
    NavigationStack {
        SpotDetailView(spot: TouristSpot.sampleSpots[0], viewModel: MapViewModel())
    }
}
