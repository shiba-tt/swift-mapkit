import Foundation
import CoreLocation
import Combine

/// ARガイド機能を管理するViewModel
@MainActor
final class ARGuideViewModel: ObservableObject {
    @Published var currentSpot: TouristSpot?
    @Published var nearbySpots: [TouristSpot] = []
    @Published var isARSessionActive = false
    @Published var guidanceText: String = ""
    @Published var showInfoPanel = false

    private let proximityThreshold: CLLocationDistance = 500 // メートル

    /// 現在位置から近くのスポットを検索
    func updateNearbySpots(from location: CLLocation) {
        nearbySpots = TouristSpot.sampleSpots.filter { spot in
            let spotLocation = CLLocation(
                latitude: spot.coordinate.latitude,
                longitude: spot.coordinate.longitude
            )
            return location.distance(from: spotLocation) <= proximityThreshold
        }.sorted { spot1, spot2 in
            let loc1 = CLLocation(latitude: spot1.coordinate.latitude, longitude: spot1.coordinate.longitude)
            let loc2 = CLLocation(latitude: spot2.coordinate.latitude, longitude: spot2.coordinate.longitude)
            return location.distance(from: loc1) < location.distance(from: loc2)
        }
    }

    /// スポットへのガイダンステキストを生成
    func generateGuidance(for spot: TouristSpot, from location: CLLocation) -> String {
        let spotLocation = CLLocation(
            latitude: spot.coordinate.latitude,
            longitude: spot.coordinate.longitude
        )
        let distance = location.distance(from: spotLocation)

        let formattedDistance: String
        if distance >= 1000 {
            formattedDistance = String(format: "%.1f km", distance / 1000)
        } else {
            formattedDistance = String(format: "%.0f m", distance)
        }

        return "\(spot.nameJapanese)まで \(formattedDistance)"
    }

    /// AR空間に表示するガイド情報を構築
    struct ARGuideInfo {
        let spot: TouristSpot
        let distance: CLLocationDistance
        let bearing: Double
        let guidanceText: String
    }

    /// 全近隣スポットのARガイド情報を取得
    func getARGuideInfos(from location: CLLocation) -> [ARGuideInfo] {
        nearbySpots.map { spot in
            let spotLocation = CLLocation(
                latitude: spot.coordinate.latitude,
                longitude: spot.coordinate.longitude
            )
            let distance = location.distance(from: spotLocation)
            let bearing = Self.bearing(from: location.coordinate, to: spot.coordinate)
            let guidance = generateGuidance(for: spot, from: location)

            return ARGuideInfo(
                spot: spot,
                distance: distance,
                bearing: bearing,
                guidanceText: guidance
            )
        }
    }

    /// 2点間の方位角を計算
    static func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let lat1 = start.latitude.degreesToRadians
        let lon1 = start.longitude.degreesToRadians
        let lat2 = end.latitude.degreesToRadians
        let lon2 = end.longitude.degreesToRadians

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)

        return (bearing.radiansToDegrees + 360).truncatingRemainder(dividingBy: 360)
    }
}

// MARK: - 角度変換ヘルパー

private extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
