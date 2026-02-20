import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showLegend = false

    var body: some View {
        ZStack {
            // メインマップ
            CrimeMapView(viewModel: viewModel)
                .ignoresSafeArea(edges: .top)

            // オーバーレイUI
            VStack {
                // 上部ツールバー
                headerToolbar

                Spacer()

                // 下部情報バー
                HStack(alignment: .bottom) {
                    // 凡例（左下）
                    LegendView(isExpanded: $showLegend)

                    Spacer()

                    // クイック情報（右下）
                    quickInfoPanel
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $viewModel.showingDetail) {
            DetailSheetView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingFilter) {
            FilterPanelView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingStats) {
            StatsView(viewModel: viewModel)
        }
    }

    // MARK: - ヘッダーツールバー
    private var headerToolbar: some View {
        HStack(spacing: 12) {
            // アプリタイトル
            HStack(spacing: 6) {
                Image(systemName: "shield.checkered")
                    .font(.headline)
                Text("防犯マップ")
                    .font(.headline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

            Spacer()

            // フィルターボタン
            Button {
                viewModel.showingFilter = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(ToolbarButtonStyle())

            // 統計ボタン
            Button {
                viewModel.showingStats = true
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
            }
            .buttonStyle(ToolbarButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - クイック情報パネル
    private var quickInfoPanel: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // 表示中の情報数
            if viewModel.showCrimes {
                quickInfoBadge(
                    icon: "exclamationmark.triangle.fill",
                    count: viewModel.filteredCrimes.count,
                    color: .red
                )
            }
            if viewModel.showCameras {
                quickInfoBadge(
                    icon: "video.fill",
                    count: viewModel.filteredCameras.count,
                    color: .blue
                )
            }
            if viewModel.showDangerZones {
                quickInfoBadge(
                    icon: "circle.dashed",
                    count: viewModel.filteredDangerZones.count,
                    color: .orange
                )
            }
        }
    }

    private func quickInfoBadge(icon: String, count: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
    }
}

// MARK: - ツールバーボタンスタイル
struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .frame(width: 40, height: 40)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
