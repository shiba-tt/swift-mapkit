import MapKit
import SwiftUI

/// メインコンテンツビュー - マップ＋オーバーレイUI
public struct ContentView: View {
    @State private var viewModel = TradeAreaViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            // マップ
            TradeAreaMapView(viewModel: viewModel)
                .ignoresSafeArea(edges: .all)
                .onLongPressGesture(minimumDuration: 0.5) {
                    // ロングプレスで中心点変更は MapReader で実装
                }

            // オーバーレイUI
            VStack {
                // 上部コントロールパネル
                HStack(alignment: .top) {
                    ControlPanelView(viewModel: viewModel)
                        .frame(maxWidth: 320)

                    Spacer()

                    // 右側ツールバー
                    toolbarButtons
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                // 下部情報バー
                if !viewModel.competitors.isEmpty {
                    bottomInfoBar
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .sheet(item: $viewModel.selectedCompetitor) { competitor in
            CompetitorDetailSheet(
                competitor: competitor,
                center: viewModel.config.center
            )
        }
        .sheet(isPresented: $viewModel.showCompetitorList) {
            CompetitorListView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSettings) {
            DistanceRingSettingsView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.updateCamera()
        }
    }

    // MARK: - ツールバーボタン

    private var toolbarButtons: some View {
        VStack(spacing: 8) {
            // 距離圏設定
            ToolbarButton(icon: "circle.dashed", label: "距離圏") {
                viewModel.showSettings = true
            }

            // 競合リスト
            ToolbarButton(icon: "list.bullet", label: "一覧") {
                viewModel.showCompetitorList = true
            }

            // 中心リセット
            ToolbarButton(icon: "location.viewfinder", label: "中心") {
                viewModel.updateCamera()
            }

            // クリア
            if !viewModel.competitors.isEmpty {
                ToolbarButton(icon: "trash", label: "クリア") {
                    withAnimation { viewModel.clearResults() }
                }
            }
        }
    }

    // MARK: - 下部情報バー

    private var bottomInfoBar: some View {
        HStack(spacing: 12) {
            // カテゴリ別サマリー
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.competitorCountByCategory, id: \.category) { item in
                        HStack(spacing: 4) {
                            Image(systemName: item.category.icon)
                                .font(.caption2)
                                .foregroundStyle(item.category.color)
                            Text("\(item.category.rawValue): \(item.count)")
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }

            Spacer()

            // 全件数
            Text("計 \(viewModel.totalCompetitorCount) 件")
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.blue.opacity(0.9), in: Capsule())
                .foregroundStyle(.white)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

/// ツールバーボタンコンポーネント
struct ToolbarButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 8))
            }
            .frame(width: 44, height: 44)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }
}
