import SwiftUI

/// メインコンテンツビュー（タブ構成）
struct ContentView: View {
    @StateObject private var viewModel = HistoricalSiteViewModel()
    @State private var selectedTab: Tab = .map
    @State private var isShowingRouteList = false

    enum Tab: Hashable {
        case map
        case list
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // マップタブ
            ZStack(alignment: .bottomLeading) {
                HistoricalMapView(viewModel: viewModel)

                // ルート表示ボタン
                if !viewModel.isShowingRoute {
                    Button {
                        isShowingRouteList = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "figure.walk")
                            Text("散策ルート")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 16)
                }
            }
            .tabItem {
                Label("マップ", systemImage: "map.fill")
            }
            .tag(Tab.map)

            // 一覧タブ
            SiteListView(viewModel: viewModel)
                .tabItem {
                    Label("一覧", systemImage: "list.bullet")
                }
                .tag(Tab.list)
        }
        .sheet(isPresented: $isShowingRouteList) {
            RouteListView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
