import CoreLocation

struct WalkingRoute: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let totalDistance: CLLocationDistance
    let estimatedTime: TimeInterval
    let center: CLLocationCoordinate2D
    let radius: CLLocationDistance
}
