import Foundation
import CoreLocation

/// 学区データモデル
struct SchoolDistrict: Identifiable {
    let id = UUID()
    let name: String
    let level: SchoolLevel
    let boundary: [CLLocationCoordinate2D]

    enum SchoolLevel: String, CaseIterable {
        case elementary = "小学校"
        case juniorHigh = "中学校"
    }
}
