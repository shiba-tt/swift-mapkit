import Foundation
import CoreLocation
import SwiftUI

/// 浸水深レベル
enum FloodDepthLevel: Int, CaseIterable, Identifiable, Comparable {
    case shallow = 0      // 0.5m未満
    case moderate = 1     // 0.5m〜1.0m
    case deep = 2         // 1.0m〜2.0m
    case veryDeep = 3     // 2.0m〜5.0m
    case extreme = 4      // 5.0m以上

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .shallow: return "0.5m未満"
        case .moderate: return "0.5m〜1.0m"
        case .deep: return "1.0m〜2.0m"
        case .veryDeep: return "2.0m〜5.0m"
        case .extreme: return "5.0m以上"
        }
    }

    var color: Color {
        switch self {
        case .shallow: return Color.yellow.opacity(0.3)
        case .moderate: return Color.orange.opacity(0.35)
        case .deep: return Color.red.opacity(0.35)
        case .veryDeep: return Color.purple.opacity(0.4)
        case .extreme: return Color.black.opacity(0.4)
        }
    }

    var strokeColor: Color {
        switch self {
        case .shallow: return .yellow
        case .moderate: return .orange
        case .deep: return .red
        case .veryDeep: return .purple
        case .extreme: return .black
        }
    }

    static func < (lhs: FloodDepthLevel, rhs: FloodDepthLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// 浸水想定区域データモデル（MapCircleで表示）
struct FloodZone: Identifiable {
    let id: UUID
    let name: String
    let center: CLLocationCoordinate2D
    let radius: CLLocationDistance
    let depthLevel: FloodDepthLevel
    let riverName: String?
    let description: String?

    init(
        id: UUID = UUID(),
        name: String,
        center: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        depthLevel: FloodDepthLevel,
        riverName: String? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.center = center
        self.radius = radius
        self.depthLevel = depthLevel
        self.riverName = riverName
        self.description = description
    }
}
