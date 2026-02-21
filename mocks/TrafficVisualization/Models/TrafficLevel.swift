import Foundation
import SwiftUI
import MapKit

/// 交通渋滞レベル
enum TrafficLevel: Int, CaseIterable, Comparable {
    case free = 0       // スムーズ
    case light = 1      // やや混雑
    case moderate = 2   // 混雑
    case heavy = 3      // 渋滞
    case blocked = 4    // 通行止め

    var displayName: String {
        switch self {
        case .free: return "スムーズ"
        case .light: return "やや混雑"
        case .moderate: return "混雑"
        case .heavy: return "渋滞"
        case .blocked: return "通行止め"
        }
    }

    var color: UIColor {
        switch self {
        case .free: return UIColor.systemGreen
        case .light: return UIColor.systemTeal
        case .moderate: return UIColor.systemYellow
        case .heavy: return UIColor.systemOrange
        case .blocked: return UIColor.systemRed
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .free: return .green
        case .light: return .teal
        case .moderate: return .yellow
        case .heavy: return .orange
        case .blocked: return .red
        }
    }

    var icon: String {
        switch self {
        case .free: return "car"
        case .light: return "car.side"
        case .moderate: return "exclamationmark.triangle"
        case .heavy: return "exclamationmark.triangle.fill"
        case .blocked: return "xmark.octagon.fill"
        }
    }

    /// 推定速度（km/h）
    var estimatedSpeed: Int {
        switch self {
        case .free: return 60
        case .light: return 40
        case .moderate: return 25
        case .heavy: return 10
        case .blocked: return 0
        }
    }

    static func < (lhs: TrafficLevel, rhs: TrafficLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
