import SwiftUI
import MapKit

// MARK: - Look Around デモ

/// LookAroundPreview（ストリートビュー）機能のデモ。
/// ランドマークを選択すると、その地点のLook Aroundプレビューを表示する。
struct LookAroundDemo: View {

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        )
    )
    @State private var selectedLandmark: Landmark? = nil
    @State private var lookAroundScene: MKLookAroundScene? = nil
    @State private var isLoadingScene = false
    @State private var showLookAround = false

    var body: some View {
        VStack(spacing: 0) {
            // マップ部分
            Map(position: $position, selection: $selectedLandmark) {
                ForEach(SampleData.tokyoLandmarks) { landmark in
                    Marker(landmark.name,
                           systemImage: landmark.systemImage,
                           coordinate: landmark.coordinate)
                    .tint(selectedLandmark?.id == landmark.id ? .red : .blue)
                    .tag(landmark)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(maxHeight: showLookAround ? .infinity : .infinity)
            .onChange(of: selectedLandmark) { _, newValue in
                if let landmark = newValue {
                    fetchLookAroundScene(for: landmark)
                } else {
                    lookAroundScene = nil
                    showLookAround = false
                }
            }

            // Look Around プレビューまたは情報パネル
            bottomPanel
        }
        .navigationTitle("Look Around")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 下部パネル

    @ViewBuilder
    private var bottomPanel: some View {
        if showLookAround, lookAroundScene != nil {
            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    if let landmark = selectedLandmark {
                        Label(landmark.name, systemImage: landmark.systemImage)
                            .font(.subheadline.bold())
                    }
                    Spacer()
                    Button {
                        withAnimation {
                            showLookAround = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Look Around プレビュー
                LookAroundPreview(scene: $lookAroundScene)
                    .frame(height: 300)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            infoPanel
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - 情報パネル

    private var infoPanel: some View {
        VStack(spacing: 8) {
            if isLoadingScene {
                ProgressView("Look Aroundデータを読み込み中...")
                    .font(.caption)
            } else if let landmark = selectedLandmark {
                if lookAroundScene != nil {
                    Button {
                        withAnimation {
                            showLookAround = true
                        }
                    } label: {
                        Label("Look Aroundを表示", systemImage: "binoculars.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Label("\(landmark.name) ではLook Aroundが利用できません",
                          systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            } else {
                Label("ランドマークを選択するとLook Aroundを表示できます",
                      systemImage: "hand.tap")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Look Around シーン取得

    private func fetchLookAroundScene(for landmark: Landmark) {
        isLoadingScene = true
        lookAroundScene = nil
        showLookAround = false

        Task {
            let request = MKLookAroundSceneRequest(coordinate: landmark.coordinate)
            do {
                let scene = try await request.scene
                await MainActor.run {
                    self.lookAroundScene = scene
                    self.isLoadingScene = false
                }
            } catch {
                await MainActor.run {
                    self.lookAroundScene = nil
                    self.isLoadingScene = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LookAroundDemo()
    }
}

