import SwiftUI

/// メインのTabView - マップ・一覧・履歴を切り替え
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PilgrimageMapView()
                .tabItem {
                    Label("マップ", systemImage: "map.fill")
                }
                .tag(0)

            SpotListView()
                .tabItem {
                    Label("スポット", systemImage: "list.bullet")
                }
                .tag(1)

            CheckInHistoryView()
                .tabItem {
                    Label("履歴", systemImage: "clock.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environment(PilgrimageSpotStore())
}
