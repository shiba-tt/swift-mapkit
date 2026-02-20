import Foundation
import MapKit

/// Calculated route information between two destinations.
struct RouteInfo: Identifiable {
    let id: UUID
    let from: Destination
    let to: Destination
    let route: MKRoute

    init(id: UUID = UUID(), from: Destination, to: Destination, route: MKRoute) {
        self.id = id
        self.from = from
        self.to = to
        self.route = route
    }

    var distance: CLLocationDistance { route.distance }

    var expectedTravelTime: TimeInterval { route.expectedTravelTime }

    var distanceText: String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(fromDistance: distance)
    }

    var travelTimeText: String {
        let hours = Int(expectedTravelTime) / 3600
        let minutes = (Int(expectedTravelTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }
}
