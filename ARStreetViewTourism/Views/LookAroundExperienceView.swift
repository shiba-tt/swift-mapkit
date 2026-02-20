import SwiftUI
import MapKit

/// Look Around 360度ビュー体験画面
struct LookAroundExperienceView: View {
    let scene: MKLookAroundScene
    let spot: TouristSpot
    @Environment(\.dismiss) private var dismiss
    @State private var isFullScreen = false
    @State private var showSpotInfo = true

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Look Aroundプレビュー（フルスクリーン）
                LookAroundPreview(initialScene: scene)
                    .ignoresSafeArea(edges: isFullScreen ? .all : [])

                // スポット情報オーバーレイ
                if showSpotInfo && !isFullScreen {
                    lookAroundInfoOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle(spot.nameJapanese)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation {
                                showSpotInfo.toggle()
                            }
                        } label: {
                            Image(systemName: showSpotInfo ? "info.circle.fill" : "info.circle")
                        }

                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                isFullScreen.toggle()
                            }
                        } label: {
                            Image(systemName: isFullScreen
                                  ? "arrow.down.right.and.arrow.up.left"
                                  : "arrow.up.left.and.arrow.down.right")
                        }
                    }
                }
            }
        }
    }

    // MARK: - 情報オーバーレイ

    private var lookAroundInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: spot.category.systemImage)
                    .foregroundStyle(categoryColor)
                Text(spot.nameJapanese)
                    .font(.headline)
                Spacer()
                Text(spot.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor.opacity(0.2))
                    .clipShape(Capsule())
            }

            Text(spot.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Label("360\u{00B0} ビュー", systemImage: "view.3d")
                    .font(.caption2)
                    .foregroundStyle(.blue)

                Label(
                    String(format: "%.4f, %.4f", spot.coordinate.latitude, spot.coordinate.longitude),
                    systemImage: "location"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            // 操作ヒント
            HStack(spacing: 8) {
                instructionBadge(icon: "hand.draw", text: "ドラッグで回転")
                instructionBadge(icon: "hand.pinch", text: "ピンチで拡大")
                instructionBadge(icon: "hand.tap", text: "タップで移動")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    private func instructionBadge(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.secondary.opacity(0.1))
        .clipShape(Capsule())
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

// MARK: - Look Aroundミニプレビュー（カード内埋め込み用）

struct LookAroundMiniPreview: View {
    let scene: MKLookAroundScene?
    let isLoading: Bool

    var body: some View {
        ZStack {
            if let scene = scene {
                LookAroundPreview(initialScene: scene)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if isLoading {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .overlay {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text("Look Around を読み込み中...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "binoculars")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("Look Around 利用不可")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
            }
        }
        .frame(height: 200)
    }
}
