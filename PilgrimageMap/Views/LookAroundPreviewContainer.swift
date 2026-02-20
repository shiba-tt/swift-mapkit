import SwiftUI
import MapKit

/// Look Aroundプレビューを表示するコンテナ
struct LookAroundPreviewContainer: View {
    let coordinate: CLLocationCoordinate2D
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Look Around を読み込み中...")
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "eye.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(errorMessage ?? "この場所ではLook Aroundを利用できません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .task {
            await fetchLookAroundScene()
        }
    }

    private func fetchLookAroundScene() async {
        isLoading = true
        defer { isLoading = false }

        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        do {
            lookAroundScene = try await request.scene
        } catch {
            errorMessage = "Look Aroundの読み込みに失敗しました"
        }
    }
}

#Preview {
    LookAroundPreviewContainer(
        coordinate: CLLocationCoordinate2D(latitude: 35.6873, longitude: 139.7194)
    )
    .padding()
}
