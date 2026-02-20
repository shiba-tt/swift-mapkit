import SwiftUI

@main
struct AccessibilityVoiceNavigatorApp: App {
    @StateObject private var viewModel = NavigationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    viewModel.requestLocationPermission()
                }
        }
    }
}
