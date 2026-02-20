import MapKit

enum RouteGeneratorError: LocalizedError {
    case noRouteFound
    case locationNotAvailable

    var errorDescription: String? {
        switch self {
        case .noRouteFound:
            return "ルートが見つかりませんでした"
        case .locationNotAvailable:
            return "現在地を取得できません"
        }
    }
}

struct RouteGenerator {

    /// 現在地から指定距離の周回散歩ルートを生成する
    /// - Parameters:
    ///   - origin: 出発地点
    ///   - distance: 希望する散歩距離（メートル）
    ///   - waypointCount: 経由地点数（4〜8推奨）
    static func generateRoute(
        from origin: CLLocationCoordinate2D,
        distance: CLLocationDistance,
        waypointCount: Int = 6
    ) async throws -> WalkingRoute {
        // 希望距離から半径を逆算
        // 実際の道路は直線より長いため、補正係数 1.3 を掛ける
        let radius = distance / (2.0 * .pi * 1.3)

        let waypoints = generateWaypoints(
            center: origin,
            radius: radius,
            count: waypointCount
        )

        var allCoordinates: [CLLocationCoordinate2D] = []
        var totalDistance: CLLocationDistance = 0
        var totalTime: TimeInterval = 0

        for i in 0..<waypoints.count {
            let start = waypoints[i]
            let end = waypoints[(i + 1) % waypoints.count]

            do {
                let segment = try await requestWalkingDirections(from: start, to: end)
                if !allCoordinates.isEmpty {
                    allCoordinates.removeLast()
                }
                allCoordinates.append(contentsOf: segment.coordinates)
                totalDistance += segment.distance
                totalTime += segment.time
            } catch {
                // MKDirections が失敗した場合は直線で接続
                if allCoordinates.isEmpty {
                    allCoordinates.append(start)
                }
                allCoordinates.append(end)
                let fallbackDistance = CLLocation(
                    latitude: start.latitude, longitude: start.longitude
                ).distance(from: CLLocation(
                    latitude: end.latitude, longitude: end.longitude
                ))
                totalDistance += fallbackDistance
                // 徒歩 5km/h として時間を概算
                totalTime += fallbackDistance / (5000.0 / 3600.0)
            }
        }

        // ルートを閉じる（始点に戻る）
        if let first = allCoordinates.first,
           let last = allCoordinates.last,
           first.latitude != last.latitude || first.longitude != last.longitude
        {
            allCoordinates.append(first)
        }

        return WalkingRoute(
            coordinates: allCoordinates,
            totalDistance: totalDistance,
            estimatedTime: totalTime,
            center: origin,
            radius: radius
        )
    }

    // MARK: - Private

    private struct RouteSegment {
        let coordinates: [CLLocationCoordinate2D]
        let distance: CLLocationDistance
        let time: TimeInterval
    }

    /// 中心点の周囲に円形に経由地点を生成する
    private static func generateWaypoints(
        center: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        count: Int
    ) -> [CLLocationCoordinate2D] {
        var waypoints: [CLLocationCoordinate2D] = [center]

        let startAngle = Double.random(in: 0..<(2.0 * .pi))

        for i in 0..<count {
            let angle = startAngle + (Double(i) / Double(count)) * 2.0 * .pi
            let jitteredRadius = radius * Double.random(in: 0.8...1.2)
            let point = coordinate(from: center, distance: jitteredRadius, bearing: angle)
            waypoints.append(point)
        }

        return waypoints
    }

    /// 基準点から指定距離・方位の座標を計算する（Vincenty 近似）
    private static func coordinate(
        from origin: CLLocationCoordinate2D,
        distance: CLLocationDistance,
        bearing: Double
    ) -> CLLocationCoordinate2D {
        let earthRadius = 6_371_000.0

        let lat1 = origin.latitude * .pi / 180.0
        let lon1 = origin.longitude * .pi / 180.0
        let angularDistance = distance / earthRadius

        let lat2 = asin(
            sin(lat1) * cos(angularDistance)
                + cos(lat1) * sin(angularDistance) * cos(bearing)
        )

        let lon2 = lon1 + atan2(
            sin(bearing) * sin(angularDistance) * cos(lat1),
            cos(angularDistance) - sin(lat1) * sin(lat2)
        )

        return CLLocationCoordinate2D(
            latitude: lat2 * 180.0 / .pi,
            longitude: lon2 * 180.0 / .pi
        )
    }

    /// MKDirections で徒歩ルートを取得する
    private static func requestWalkingDirections(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) async throws -> RouteSegment {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .walking

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        guard let route = response.routes.first else {
            throw RouteGeneratorError.noRouteFound
        }

        let pointCount = route.polyline.pointCount
        let points = route.polyline.points()
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0..<pointCount {
            coordinates.append(points[i].coordinate)
        }

        return RouteSegment(
            coordinates: coordinates,
            distance: route.distance,
            time: route.expectedTravelTime
        )
    }
}
