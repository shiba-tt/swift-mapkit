import Foundation
import CoreLocation

/// 競合店舗のテリトリー（勢力圏）を計算するサービス
struct TerritoryCalculator {

    /// カテゴリ別にテリトリーポリゴン（凸包）を計算
    func calculateTerritories(
        competitors: [Competitor],
        center: CLLocationCoordinate2D,
        maxRadius: CLLocationDistance
    ) -> [Territory] {
        let grouped = Dictionary(grouping: competitors, by: \.category)

        return grouped.compactMap { category, members in
            guard members.count >= 3 else { return nil }

            let coords = members.map(\.coordinate)
            let hull = convexHull(points: coords)

            guard hull.count >= 3 else { return nil }

            return Territory(
                category: category,
                polygon: hull,
                competitorCount: members.count
            )
        }
    }

    /// 個別競合の影響圏を計算（最近接同業他社までの距離に基づく）
    func calculateInfluenceZones(
        competitors: [Competitor],
        defaultRadius: CLLocationDistance = 200
    ) -> [InfluenceZone] {
        competitors.map { competitor in
            let sameCategory = competitors.filter {
                $0.category == competitor.category && $0.id != competitor.id
            }

            let nearestDistance: CLLocationDistance
            if let nearest = sameCategory.min(by: {
                distance(from: competitor.coordinate, to: $0.coordinate)
                    < distance(from: competitor.coordinate, to: $1.coordinate)
            }) {
                nearestDistance = distance(
                    from: competitor.coordinate,
                    to: nearest.coordinate
                )
            } else {
                nearestDistance = defaultRadius * 2
            }

            let radius = max(nearestDistance / 2, 50)

            return InfluenceZone(
                competitor: competitor,
                radius: min(radius, 1000)
            )
        }
    }

    // MARK: - Convex Hull (Graham Scan)

    /// Graham Scanアルゴリズムによる凸包計算
    private func convexHull(points: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard points.count >= 3 else { return points }

        // 最も下（緯度が小さい）のポイントを基準に
        let sorted = points.sorted {
            if $0.latitude != $1.latitude { return $0.latitude < $1.latitude }
            return $0.longitude < $1.longitude
        }

        guard let pivot = sorted.first else { return points }

        // 基準点からの偏角でソート
        let byAngle = sorted.dropFirst().sorted {
            let angle1 = atan2(
                $0.latitude - pivot.latitude,
                $0.longitude - pivot.longitude
            )
            let angle2 = atan2(
                $1.latitude - pivot.latitude,
                $1.longitude - pivot.longitude
            )
            if angle1 != angle2 { return angle1 < angle2 }
            return distanceSquared(pivot, $0) < distanceSquared(pivot, $1)
        }

        var stack: [CLLocationCoordinate2D] = [pivot]

        for point in byAngle {
            while stack.count > 1 && crossProduct(stack[stack.count - 2], stack[stack.count - 1], point) <= 0 {
                stack.removeLast()
            }
            stack.append(point)
        }

        return stack
    }

    /// 外積の計算（回転方向の判定に使用）
    private func crossProduct(
        _ o: CLLocationCoordinate2D,
        _ a: CLLocationCoordinate2D,
        _ b: CLLocationCoordinate2D
    ) -> Double {
        (a.longitude - o.longitude) * (b.latitude - o.latitude)
            - (a.latitude - o.latitude) * (b.longitude - o.longitude)
    }

    /// 座標間の距離の二乗（比較用、実際の距離は不要）
    private func distanceSquared(
        _ a: CLLocationCoordinate2D,
        _ b: CLLocationCoordinate2D
    ) -> Double {
        let dlat = a.latitude - b.latitude
        let dlon = a.longitude - b.longitude
        return dlat * dlat + dlon * dlon
    }

    /// 2座標間の実距離（メートル）
    private func distance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return loc1.distance(from: loc2)
    }
}
