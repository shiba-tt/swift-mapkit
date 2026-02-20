import SwiftUI
import ARKit
import RealityKit

/// AR歴史体験ビュー - カメラ映像に歴史的情報をオーバーレイ表示
struct ARHistoricalView: View {
    let site: HistoricalSite
    let onDismiss: () -> Void

    @State private var isInfoExpanded = false
    @State private var showingOverlay = true
    @State private var overlayOpacity: Double = 0.3

    var body: some View {
        ZStack {
            // ARカメラビュー
            ARViewContainer(site: site)
                .ignoresSafeArea()

            // 歴史的風景オーバーレイ
            if showingOverlay {
                historicalOverlay
            }

            // UIコントロール
            VStack {
                // トップバー
                topBar

                Spacer()

                // 情報パネル
                bottomInfoPanel
            }
        }
        .statusBarHidden()
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }

            Spacer()

            Text("AR歴史体験")
                .font(.headline)
                .foregroundStyle(.white)
                .shadow(radius: 4)

            Spacer()

            // オーバーレイ切替
            Button {
                withAnimation {
                    showingOverlay.toggle()
                }
            } label: {
                Image(systemName: showingOverlay ? "eye.fill" : "eye.slash.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.black.opacity(0.5), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Historical Overlay

    private var historicalOverlay: some View {
        ZStack {
            // セピアトーンのオーバーレイ
            Color.brown
                .opacity(overlayOpacity)
                .ignoresSafeArea()

            // 時代の雰囲気を表現するビネット効果
            RadialGradient(
                colors: [.clear, .black.opacity(overlayOpacity)],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()

            // 方位表示（コンパス風）
            VStack {
                Spacer()
                    .frame(height: 80)

                HStack {
                    Spacer()
                    CompassOverlay(era: site.era)
                        .frame(width: 80, height: 80)
                        .padding(.trailing, 20)
                }

                Spacer()
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Bottom Info Panel

    private var bottomInfoPanel: some View {
        VStack(spacing: 0) {
            // 展開/折りたたみハンドル
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isInfoExpanded.toggle()
                }
            } label: {
                VStack(spacing: 4) {
                    Capsule()
                        .fill(.white.opacity(0.5))
                        .frame(width: 40, height: 4)
                        .padding(.top, 8)

                    HStack {
                        Image(systemName: site.category.iconName)
                            .foregroundStyle(eraColor)
                        Text(site.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                        EraTag(era: site.era)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }

            if isInfoExpanded {
                expandedInfo
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // オーバーレイ透明度スライダー
            if showingOverlay {
                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundStyle(.white.opacity(0.7))
                    Slider(value: $overlayOpacity, in: 0.0...0.7)
                        .tint(eraColor)
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .background(.ultraThinMaterial.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Expanded Info

    private var expandedInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            // AR説明文
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(eraColor)
                    Text("当時の風景")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

                Text(site.arDescription)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineSpacing(2)
            }

            // 年代情報
            HStack(spacing: 12) {
                ARInfoChip(icon: "calendar", text: site.yearBuilt)
                ARInfoChip(icon: "building.2", text: site.category.rawValue)
            }

            // 関連人物
            if !site.historicalFigures.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("関連人物")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(site.historicalFigures, id: \.self) { figure in
                                Text(figure)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.white.opacity(0.2), in: Capsule())
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
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

// MARK: - AR Info Chip

struct ARInfoChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .foregroundStyle(.white.opacity(0.8))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.15), in: Capsule())
    }
}

// MARK: - Compass Overlay

struct CompassOverlay: View {
    let era: HistoricalEra

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.3))
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )

            VStack(spacing: 2) {
                Text(era.rawValue)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)

                Text(era.yearRange.components(separatedBy: "〜").first ?? "")
                    .font(.system(size: 7))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - ARView Container

struct ARViewContainer: UIViewRepresentable {
    let site: HistoricalSite

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // AR設定
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]

        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }

        arView.session.run(configuration)

        // 史跡情報のアンカーを追加
        addHistoricalAnchor(to: arView)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    private func addHistoricalAnchor(to arView: ARView) {
        // 3Dテキストで史跡名を表示
        let anchor = AnchorEntity(plane: .horizontal)

        // テキストメッシュで史跡名
        let textMesh = MeshResource.generateText(
            site.name,
            extrusionDepth: 0.02,
            font: .systemFont(ofSize: 0.1, weight: .bold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let material = SimpleMaterial(
            color: UIColor(eraUIColor),
            isMetallic: true
        )

        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        textEntity.position = SIMD3(0, 0.5, -2)

        anchor.addChild(textEntity)

        // 時代テキスト
        let eraMesh = MeshResource.generateText(
            site.era.rawValue,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.06),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let eraEntity = ModelEntity(
            mesh: eraMesh,
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )
        eraEntity.position = SIMD3(0, 0.35, -2)
        anchor.addChild(eraEntity)

        // 地面にマーカーを設置
        let markerMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
        let markerMaterial = SimpleMaterial(
            color: UIColor(eraUIColor).withAlphaComponent(0.5),
            isMetallic: false
        )
        let markerEntity = ModelEntity(mesh: markerMesh, materials: [markerMaterial])
        markerEntity.position = SIMD3(0, 0.01, -2)
        anchor.addChild(markerEntity)

        arView.scene.addAnchor(anchor)
    }

    private var eraUIColor: UIColor {
        switch site.era {
        case .jomon, .yayoi, .kofun: return .brown
        case .asuka, .nara: return .orange
        case .heian: return .purple
        case .kamakura, .muromachi: return .systemBlue
        case .azuchiMomoyama: return .red
        case .edo: return .systemIndigo
        case .meiji, .taisho, .showa: return .systemGreen
        }
    }
}
