import MapKit
import SwiftUI

@MainActor
final class RouteViewModel: ObservableObject {
    @Published var route: WalkingRoute?
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var desiredDistance: Double = 2000 // メートル
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)

    let locationManager = LocationManager()

    func generateRoute() async {
        guard let location = locationManager.currentLocation else {
            errorMessage = "現在地を取得できません。位置情報の許可を確認してください。"
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            let newRoute = try await RouteGenerator.generateRoute(
                from: location.coordinate,
                distance: desiredDistance
            )
            route = newRoute
            let span = newRoute.radius * 2.8
            let region = MKCoordinateRegion(
                center: newRoute.center,
                latitudinalMeters: span,
                longitudinalMeters: span
            )
            cameraPosition = .region(region)
        } catch {
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }

    func clearRoute() {
        route = nil
        errorMessage = nil
    }
}
