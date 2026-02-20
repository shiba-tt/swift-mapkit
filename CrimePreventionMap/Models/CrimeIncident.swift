import Foundation
import CoreLocation
import SwiftUI

// MARK: - 犯罪種別
enum CrimeType: String, CaseIterable, Identifiable {
    case theft = "窃盗"
    case robbery = "強盗"
    case assault = "暴行"
    case fraud = "詐欺"
    case vandalism = "器物損壊"
    case suspiciousPerson = "不審者"
    case molester = "痴漢"
    case stalking = "ストーカー"
    case other = "その他"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .theft: return "lock.open.fill"
        case .robbery: return "exclamationmark.triangle.fill"
        case .assault: return "hand.raised.fill"
        case .fraud: return "phone.fill"
        case .vandalism: return "hammer.fill"
        case .suspiciousPerson: return "eye.fill"
        case .molester: return "figure.walk"
        case .stalking: return "person.fill.viewfinder"
        case .other: return "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .theft: return .orange
        case .robbery: return .red
        case .assault: return .red
        case .fraud: return .purple
        case .vandalism: return .brown
        case .suspiciousPerson: return .yellow
        case .molester: return .pink
        case .stalking: return .indigo
        case .other: return .gray
        }
    }
}

// MARK: - 犯罪発生情報
struct CrimeIncident: Identifiable {
    let id: UUID
    let type: CrimeType
    let title: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let date: Date
    let severity: Severity
    let isResolved: Bool

    enum Severity: Int, CaseIterable, Comparable {
        case low = 1
        case medium = 2
        case high = 3
        case critical = 4

        static func < (lhs: Severity, rhs: Severity) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        var label: String {
            switch self {
            case .low: return "低"
            case .medium: return "中"
            case .high: return "高"
            case .critical: return "危険"
            }
        }

        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }

    init(
        id: UUID = UUID(),
        type: CrimeType,
        title: String,
        description: String,
        coordinate: CLLocationCoordinate2D,
        date: Date,
        severity: Severity,
        isResolved: Bool = false
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.coordinate = coordinate
        self.date = date
        self.severity = severity
        self.isResolved = isResolved
    }
}
