import Foundation
import MapKit

/// 道路の交通セグメント（区間）
struct TrafficSegment: Identifiable {
    let id: UUID
    let coordinates: [CLLocationCoordinate2D]
    let trafficLevel: TrafficLevel
    let roadName: String
    let speedKmh: Int

    init(
        id: UUID = UUID(),
        coordinates: [CLLocationCoordinate2D],
        trafficLevel: TrafficLevel,
        roadName: String,
        speedKmh: Int? = nil
    ) {
        self.id = id
        self.coordinates = coordinates
        self.trafficLevel = trafficLevel
        self.roadName = roadName
        self.speedKmh = speedKmh ?? trafficLevel.estimatedSpeed
    }

    /// セグメントのMKPolylineを生成
    func polyline() -> TrafficPolyline {
        var coords = coordinates
        let polyline = TrafficPolyline(
            coordinates: &coords,
            count: coords.count
        )
        polyline.trafficLevel = trafficLevel
        polyline.segmentId = id
        return polyline
    }

    /// セグメントの距離（メートル）
    var distanceMeters: Double {
        guard coordinates.count >= 2 else { return 0 }
        var total: Double = 0
        for i in 0..<(coordinates.count - 1) {
            let from = CLLocation(
                latitude: coordinates[i].latitude,
                longitude: coordinates[i].longitude
            )
            let to = CLLocation(
                latitude: coordinates[i + 1].latitude,
                longitude: coordinates[i + 1].longitude
            )
            total += from.distance(from: to)
        }
        return total
    }

    /// 中心座標
    var center: CLLocationCoordinate2D {
        guard !coordinates.isEmpty else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        let midIndex = coordinates.count / 2
        return coordinates[midIndex]
    }
}

/// 交通情報付きポリライン
class TrafficPolyline: MKPolyline {
    var trafficLevel: TrafficLevel = .free
    var segmentId: UUID = UUID()
}
