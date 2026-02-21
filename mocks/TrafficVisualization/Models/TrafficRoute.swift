import Foundation
import MapKit

/// 交通ルート（複数セグメントで構成）
struct TrafficRoute: Identifiable {
    let id: UUID
    let name: String
    let segments: [TrafficSegment]
    let isDetour: Bool

    init(
        id: UUID = UUID(),
        name: String,
        segments: [TrafficSegment],
        isDetour: Bool = false
    ) {
        self.id = id
        self.name = name
        self.segments = segments
        self.isDetour = isDetour
    }

    /// ルート全体の距離（メートル）
    var totalDistanceMeters: Double {
        segments.reduce(0) { $0 + $1.distanceMeters }
    }

    /// ルート全体の距離表示文字列
    var distanceText: String {
        let km = totalDistanceMeters / 1000.0
        if km < 1 {
            return String(format: "%.0f m", totalDistanceMeters)
        }
        return String(format: "%.1f km", km)
    }

    /// 最も深刻な渋滞レベル
    var worstTrafficLevel: TrafficLevel {
        segments.map(\.trafficLevel).max() ?? .free
    }

    /// 渋滞セグメントの数
    var congestedSegmentCount: Int {
        segments.filter { $0.trafficLevel >= .moderate }.count
    }

    /// 推定所要時間（秒）
    var estimatedTravelTimeSeconds: Double {
        segments.reduce(0) { total, segment in
            let speed = max(Double(segment.speedKmh), 1.0)
            let distanceKm = segment.distanceMeters / 1000.0
            return total + (distanceKm / speed) * 3600
        }
    }

    /// 所要時間の表示文字列
    var travelTimeText: String {
        let minutes = Int(estimatedTravelTimeSeconds / 60)
        if minutes < 60 {
            return "\(minutes)分"
        }
        let hours = minutes / 60
        let remainMinutes = minutes % 60
        return "\(hours)時間\(remainMinutes)分"
    }

    /// ルートの全座標
    var allCoordinates: [CLLocationCoordinate2D] {
        segments.flatMap(\.coordinates)
    }

    /// ルートを含むMKMapRectを計算
    var boundingMapRect: MKMapRect {
        let coords = allCoordinates
        guard !coords.isEmpty else {
            return MKMapRect.world
        }

        var minLat = coords[0].latitude
        var maxLat = coords[0].latitude
        var minLon = coords[0].longitude
        var maxLon = coords[0].longitude

        for coord in coords {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }

        let topLeft = MKMapPoint(CLLocationCoordinate2D(latitude: maxLat, longitude: minLon))
        let bottomRight = MKMapPoint(CLLocationCoordinate2D(latitude: minLat, longitude: maxLon))

        return MKMapRect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }
}

/// 渋滞ポイント（アノテーション用）
struct CongestionPoint: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let trafficLevel: TrafficLevel
    let roadName: String
    let description: String

    init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        trafficLevel: TrafficLevel,
        roadName: String,
        description: String
    ) {
        self.id = id
        self.coordinate = coordinate
        self.trafficLevel = trafficLevel
        self.roadName = roadName
        self.description = description
    }
}
