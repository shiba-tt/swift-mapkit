import SwiftUI
import ARKit
import RealityKit
import CoreLocation

/// ARKit仮想ガイドビュー - AR空間に観光情報を表示
struct ARGuideView: UIViewRepresentable {
    @ObservedObject var viewModel: ARGuideViewModel
    let spots: [TouristSpot]
    var userLocation: CLLocation?

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // ARワールドトラッキング設定
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }

        arView.session.run(configuration)
        context.coordinator.arView = arView

        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        guard let location = userLocation else { return }
        context.coordinator.updateAnnotations(
            spots: spots,
            userLocation: location,
            arView: arView
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var arView: ARView?
        private var anchorEntities: [UUID: AnchorEntity] = [:]

        func updateAnnotations(
            spots: [TouristSpot],
            userLocation: CLLocation,
            arView: ARView
        ) {
            // 既存のアンカーをクリア
            for (id, anchor) in anchorEntities {
                if !spots.contains(where: { $0.id == id }) {
                    arView.scene.removeAnchor(anchor)
                    anchorEntities.removeValue(forKey: id)
                }
            }

            // 各スポットにAR注釈を配置
            for spot in spots {
                if anchorEntities[spot.id] != nil {
                    continue
                }

                let spotLocation = CLLocation(
                    latitude: spot.coordinate.latitude,
                    longitude: spot.coordinate.longitude
                )

                let distance = userLocation.distance(from: spotLocation)
                let bearing = ARGuideViewModel.bearing(
                    from: userLocation.coordinate,
                    to: spot.coordinate
                )

                // AR空間での位置を計算（最大表示距離を制限）
                let displayDistance = min(Float(distance), 50.0)
                let bearingRad = Float(bearing) * .pi / 180

                let x = displayDistance * sin(bearingRad)
                let z = -displayDistance * cos(bearingRad)

                let anchorEntity = AnchorEntity(world: SIMD3<Float>(x, 1.5, z))

                // スポット情報パネルを作成
                let infoEntity = createInfoPanel(for: spot, distance: distance)
                anchorEntity.addChild(infoEntity)

                // 方向指示矢印を追加
                let arrowEntity = createDirectionArrow(for: spot)
                arrowEntity.position = SIMD3<Float>(0, -0.3, 0)
                anchorEntity.addChild(arrowEntity)

                arView.scene.addAnchor(anchorEntity)
                anchorEntities[spot.id] = anchorEntity
            }
        }

        /// スポット情報パネルエンティティを生成
        private func createInfoPanel(for spot: TouristSpot, distance: CLLocationDistance) -> ModelEntity {
            let distanceText: String
            if distance >= 1000 {
                distanceText = String(format: "%.1f km", distance / 1000)
            } else {
                distanceText = String(format: "%.0f m", distance)
            }

            let text = "\(spot.nameJapanese)\n\(distanceText)"

            let mesh = MeshResource.generateText(
                text,
                extrusionDepth: 0.001,
                font: .systemFont(ofSize: 0.06, weight: .bold),
                containerFrame: .zero,
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )

            let material = SimpleMaterial(
                color: colorForCategory(spot.category),
                isMetallic: false
            )

            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.generateCollisionShapes(recursive: false)

            // ビルボード制約（常にカメラに向く）
            return entity
        }

        /// 方向指示矢印エンティティを生成
        private func createDirectionArrow(for spot: TouristSpot) -> ModelEntity {
            let mesh = MeshResource.generateBox(
                width: 0.04,
                height: 0.005,
                depth: 0.08,
                cornerRadius: 0.002
            )
            let material = SimpleMaterial(
                color: colorForCategory(spot.category).withAlphaComponent(0.8),
                isMetallic: true
            )
            return ModelEntity(mesh: mesh, materials: [material])
        }

        private func colorForCategory(_ category: TouristSpot.Category) -> UIColor {
            switch category {
            case .temple: return .orange
            case .shrine: return .red
            case .landmark: return .purple
            case .nature: return .systemGreen
            case .modern: return .systemBlue
            }
        }
    }
}

// MARK: - ARガイドコンテナビュー（ARView + SwiftUI オーバーレイ）

struct ARGuideContainerView: View {
    @ObservedObject var arViewModel: ARGuideViewModel
    @ObservedObject var mapViewModel: MapViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var showNearbyList = false
    @State private var selectedSpotForLookAround: TouristSpot?
    @State private var lookAroundScene: MKLookAroundScene?

    var body: some View {
        NavigationStack {
            ZStack {
                if locationManager.authorizationStatus == .authorizedWhenInUse ||
                    locationManager.authorizationStatus == .authorizedAlways {
                    // ARビュー
                    ARGuideView(
                        viewModel: arViewModel,
                        spots: arViewModel.nearbySpots,
                        userLocation: locationManager.location
                    )
                    .ignoresSafeArea()

                    // ARオーバーレイUI
                    VStack {
                        Spacer()
                        arOverlayControls
                    }
                } else {
                    locationPermissionView
                }
            }
            .navigationTitle("ARガイド")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNearbyList = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showNearbyList) {
                nearbySpotsList
            }
            .sheet(item: $selectedSpotForLookAround) { spot in
                if let scene = lookAroundScene {
                    LookAroundExperienceView(scene: scene, spot: spot)
                }
            }
            .onChange(of: locationManager.location) { _, newLocation in
                if let location = newLocation {
                    arViewModel.updateNearbySpots(from: location)
                }
            }
        }
    }

    // MARK: - ARオーバーレイコントロール

    private var arOverlayControls: some View {
        VStack(spacing: 12) {
            // 近くのスポットカード（横スクロール）
            if !arViewModel.nearbySpots.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(arViewModel.nearbySpots) { spot in
                            ARSpotCard(spot: spot, userLocation: locationManager.location) {
                                Task {
                                    await loadLookAroundForSpot(spot)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                HStack {
                    Image(systemName: "location.magnifyingglass")
                    Text("近くの観光スポットを検索中...")
                }
                .font(.callout)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }

            // ステータスバー
            HStack(spacing: 16) {
                Label(
                    "\(arViewModel.nearbySpots.count) スポット",
                    systemImage: "mappin.circle"
                )
                if let location = locationManager.location {
                    Label(
                        String(format: "%.4f, %.4f",
                               location.coordinate.latitude,
                               location.coordinate.longitude),
                        systemImage: "location"
                    )
                }
            }
            .font(.caption)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.bottom, 8)
        }
    }

    // MARK: - 位置情報権限ビュー

    private var locationPermissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("位置情報の許可が必要です")
                .font(.title2.weight(.semibold))

            Text("ARガイド機能を使用するには、位置情報へのアクセスを許可してください。近くの観光スポットを検出し、AR空間に表示します。")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("設定を開く") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - 近くのスポットリスト

    private var nearbySpotsList: some View {
        NavigationStack {
            List(arViewModel.nearbySpots) { spot in
                HStack {
                    Image(systemName: spot.category.systemImage)
                        .foregroundStyle(colorForCategory(spot.category))
                        .frame(width: 30)

                    VStack(alignment: .leading) {
                        Text(spot.nameJapanese)
                            .font(.headline)
                        if let location = locationManager.location {
                            Text(arViewModel.generateGuidance(for: spot, from: location))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("近くのスポット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        showNearbyList = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - ヘルパー

    private func loadLookAroundForSpot(_ spot: TouristSpot) async {
        let request = MKLookAroundSceneRequest(coordinate: spot.coordinate)
        do {
            if let scene = try await request.scene {
                lookAroundScene = scene
                selectedSpotForLookAround = spot
            }
        } catch {
            print("Look Around error: \(error)")
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

// MARK: - ARスポットカード

struct ARSpotCard: View {
    let spot: TouristSpot
    let userLocation: CLLocation?
    let onLookAroundTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: spot.category.systemImage)
                    .foregroundStyle(categoryColor)
                Text(spot.nameJapanese)
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            if let location = userLocation {
                let spotLocation = CLLocation(
                    latitude: spot.coordinate.latitude,
                    longitude: spot.coordinate.longitude
                )
                let distance = location.distance(from: spotLocation)
                Text(distance >= 1000
                     ? String(format: "%.1f km", distance / 1000)
                     : String(format: "%.0f m", distance))
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Button(action: onLookAroundTap) {
                HStack(spacing: 4) {
                    Image(systemName: "binoculars")
                    Text("Look Around")
                }
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
        }
        .padding(12)
        .frame(width: 180)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
