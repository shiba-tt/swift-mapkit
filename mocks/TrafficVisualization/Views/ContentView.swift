import SwiftUI
import MapKit

/// メインコンテンツビュー - 地図と交通情報パネルを統合
struct ContentView: View {
    @StateObject private var viewModel = TrafficViewModel()
    @State private var showInfoPanel = true
    @State private var sheetDetent: PresentationDetent = .fraction(0.35)

    var body: some View {
        ZStack(alignment: .top) {
            // 地図ビュー
            TrafficMapView(
                routes: viewModel.visibleRoutes,
                congestionPoints: viewModel.visibleCongestionPoints,
                showTrafficLayer: viewModel.showTrafficLayer,
                region: viewModel.defaultRegion
            )
            .ignoresSafeArea()

            // 上部のコントロールバー
            controlBar
        }
        .sheet(isPresented: $showInfoPanel) {
            TrafficInfoPanel(viewModel: viewModel)
                .presentationDetents([
                    .fraction(0.12),
                    .fraction(0.35),
                    .fraction(0.7),
                ])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    // MARK: - コントロールバー

    private var controlBar: some View {
        HStack(spacing: 12) {
            // 凡例ボタン
            legendView

            Spacer()

            // フィルターボタン群
            filterButtons
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - 凡例

    private var legendView: some View {
        HStack(spacing: 6) {
            ForEach(TrafficLevel.allCases, id: \.rawValue) { level in
                HStack(spacing: 3) {
                    Circle()
                        .fill(level.swiftUIColor)
                        .frame(width: 8, height: 8)
                    Text(level.displayName)
                        .font(.system(size: 9))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    // MARK: - フィルターボタン

    private var filterButtons: some View {
        HStack(spacing: 8) {
            // Apple Maps 交通レイヤートグル
            FilterButton(
                icon: "car.2",
                isActive: viewModel.showTrafficLayer,
                action: { viewModel.showTrafficLayer.toggle() }
            )

            // 迂回ルート表示トグル
            FilterButton(
                icon: "arrow.triangle.swap",
                isActive: viewModel.showDetourRoutes,
                action: { viewModel.showDetourRoutes.toggle() }
            )

            // 渋滞ポイント表示トグル
            FilterButton(
                icon: "mappin.and.ellipse",
                isActive: viewModel.showCongestionPoints,
                action: { viewModel.showCongestionPoints.toggle() }
            )
        }
    }
}

// MARK: - フィルターボタン

struct FilterButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isActive ? .white : .primary)
                .frame(width: 36, height: 36)
                .background(isActive ? Color.blue : Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
        }
    }
}

// MARK: - プレビュー

#Preview {
    ContentView()
}
