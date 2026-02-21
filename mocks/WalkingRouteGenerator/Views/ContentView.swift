import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RouteViewModel()

    var body: some View {
        ZStack {
            mapView

            VStack {
                Spacer()
                RouteControlPanel(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.locationManager.requestPermission()
        }
    }

    private var mapView: some View {
        Map(position: $viewModel.cameraPosition) {
            UserAnnotation()

            if let route = viewModel.route {
                // 散歩ルートのポリライン
                MapPolyline(coordinates: route.coordinates)
                    .stroke(.blue, lineWidth: 5)

                // ルート範囲を示す円
                MapCircle(center: route.center, radius: route.radius)
                    .foregroundStyle(.blue.opacity(0.08))
                    .stroke(.blue.opacity(0.3), lineWidth: 2)

                // 出発・到着地点マーカー
                if let start = route.coordinates.first {
                    Annotation("スタート", coordinate: start) {
                        Image(systemName: "figure.walk.departure")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.green, in: Circle())
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([
            .park, .publicTransport, .restroom, .cafe,
        ])))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
}

#Preview {
    ContentView()
}
