import Foundation
import CoreLocation

/// 不動産物件データモデル
struct Property: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let price: Int
    let layout: String
    let area: Double
    let buildYear: Int
    let nearestStation: String
    let walkMinutes: Int

    /// 価格表示（万円）
    var priceText: String {
        if price >= 10000 {
            let oku = price / 10000
            let man = price % 10000
            if man == 0 {
                return "\(oku)億円"
            }
            return "\(oku)億\(man)万円"
        }
        return "\(price)万円"
    }

    /// 築年数
    var buildAge: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = currentYear - buildYear
        if age <= 0 { return "新築" }
        return "築\(age)年"
    }
}
