import SwiftUI
import MapKit

/// メインコンテンツビュー
struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        CommunityMapView(viewModel: viewModel, locationManager: locationManager)
            .onAppear {
                locationManager.requestPermission()
            }
            .ignoresSafeArea(.container, edges: .top)
    }
}

#Preview {
    ContentView()
}
