import SwiftUI

@main
struct PilgrimageMapApp: App {
    @State private var store = PilgrimageSpotStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
