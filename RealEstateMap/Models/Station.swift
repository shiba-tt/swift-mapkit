import Foundation
import CoreLocation

/// 駅データモデル
struct Station: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let line: String

    /// 徒歩圏の半径（メートル）- 徒歩1分=80mで計算
    var walkingRadiusForMinutes: [Int: Double] {
        [5: 400, 10: 800, 15: 1200]
    }
}
