import Foundation
import MapKit

/// Custom MKOverlay that represents a heatmap of environmental data
final class HeatmapOverlay: NSObject, MKOverlay {

    /// Individual data points with location and intensity
    struct DataPoint {
        let coordinate: CLLocationCoordinate2D
        let intensity: Double  // 0.0 to 1.0
    }

    let dataPoints: [DataPoint]
    let radius: CLLocationDistance  // Influence radius in meters

    /// The center coordinate of the overlay (average of all data points)
    let coordinate: CLLocationCoordinate2D

    /// The bounding rectangle that encompasses all data points plus radius
    let boundingMapRect: MKMapRect

    /// The type of data displayed
    let dataType: HeatmapDataType

    init(dataPoints: [DataPoint], radius: CLLocationDistance = 400, dataType: HeatmapDataType) {
        self.dataPoints = dataPoints
        self.radius = radius
        self.dataType = dataType

        // Calculate center coordinate
        guard !dataPoints.isEmpty else {
            self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            self.boundingMapRect = MKMapRect.world
            super.init()
            return
        }

        let totalLat = dataPoints.reduce(0.0) { $0 + $1.coordinate.latitude }
        let totalLon = dataPoints.reduce(0.0) { $0 + $1.coordinate.longitude }
        self.coordinate = CLLocationCoordinate2D(
            latitude: totalLat / Double(dataPoints.count),
            longitude: totalLon / Double(dataPoints.count)
        )

        // Calculate bounding rect with padding for the radius
        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLon = Double.greatestFiniteMagnitude
        var maxLon = -Double.greatestFiniteMagnitude

        for point in dataPoints {
            minLat = min(minLat, point.coordinate.latitude)
            maxLat = max(maxLat, point.coordinate.latitude)
            minLon = min(minLon, point.coordinate.longitude)
            maxLon = max(maxLon, point.coordinate.longitude)
        }

        // Add padding for the influence radius (~0.005 degrees ≈ 500m)
        let padding = radius / 111_000.0  // rough degree conversion
        let topLeft = MKMapPoint(CLLocationCoordinate2D(
            latitude: maxLat + padding,
            longitude: minLon - padding
        ))
        let bottomRight = MKMapPoint(CLLocationCoordinate2D(
            latitude: minLat - padding,
            longitude: maxLon + padding
        ))

        self.boundingMapRect = MKMapRect(
            x: min(topLeft.x, bottomRight.x),
            y: min(topLeft.y, bottomRight.y),
            width: abs(bottomRight.x - topLeft.x),
            height: abs(bottomRight.y - topLeft.y)
        )

        super.init()
    }
}
