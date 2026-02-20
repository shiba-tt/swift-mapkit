import Foundation
import CoreLocation
import SwiftUI

// MARK: - 危険レベル
enum DangerLevel: Int, CaseIterable, Identifiable, Comparable {
    case safe = 0
    case caution = 1
    case warning = 2
    case danger = 3

    var id: Int { rawValue }

    static func < (lhs: DangerLevel, rhs: DangerLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .safe: return "安全"
        case .caution: return "注意"
        case .warning: return "警戒"
        case .danger: return "危険"
        }
    }

    var color: Color {
        switch self {
        case .safe: return .green
        case .caution: return .yellow
        case .warning: return .orange
        case .danger: return .red
        }
    }

    var opacity: Double {
        switch self {
        case .safe: return 0.1
        case .caution: return 0.2
        case .warning: return 0.3
        case .danger: return 0.4
        }
    }
}

// MARK: - 危険エリア
struct DangerZone: Identifiable {
    let id: UUID
    let name: String
    let center: CLLocationCoordinate2D
    let radius: Double // メートル
    let level: DangerLevel
    let crimeCount: Int
    let description: String
    let lastUpdated: Date

    init(
        id: UUID = UUID(),
        name: String,
        center: CLLocationCoordinate2D,
        radius: Double,
        level: DangerLevel,
        crimeCount: Int,
        description: String,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.center = center
        self.radius = radius
        self.level = level
        self.crimeCount = crimeCount
        self.description = description
        self.lastUpdated = lastUpdated
    }
}
