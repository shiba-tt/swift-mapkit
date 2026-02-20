import SwiftUI

/// メインのタブビュー
struct ContentView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var arGuideViewModel = ARGuideViewModel()

    var body: some View {
        TabView {
            MapExploreView(viewModel: mapViewModel)
                .tabItem {
                    Label("マップ", systemImage: "map")
                }

            SpotListView(viewModel: mapViewModel)
                .tabItem {
                    Label("スポット", systemImage: "list.bullet")
                }

            ARGuideContainerView(
                arViewModel: arGuideViewModel,
                mapViewModel: mapViewModel
            )
            .tabItem {
                Label("ARガイド", systemImage: "arkit")
            }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
