import Foundation
import CoreLocation
import SwiftUI

// MARK: - カメラ種別
enum CameraType: String, CaseIterable, Identifiable {
    case municipal = "自治体設置"
    case police = "警察設置"
    case commercial = "商業施設"
    case residential = "マンション"
    case traffic = "交通監視"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .municipal: return "video.fill"
        case .police: return "shield.fill"
        case .commercial: return "building.2.fill"
        case .residential: return "house.fill"
        case .traffic: return "car.fill"
        }
    }

    var color: Color {
        switch self {
        case .municipal: return .blue
        case .police: return .indigo
        case .commercial: return .teal
        case .residential: return .cyan
        case .traffic: return .mint
        }
    }
}

// MARK: - 防犯カメラ情報
struct SecurityCamera: Identifiable {
    let id: UUID
    let type: CameraType
    let name: String
    let coordinate: CLLocationCoordinate2D
    let installedDate: Date
    let isActive: Bool
    let coverageRadius: Double // メートル

    init(
        id: UUID = UUID(),
        type: CameraType,
        name: String,
        coordinate: CLLocationCoordinate2D,
        installedDate: Date,
        isActive: Bool = true,
        coverageRadius: Double = 50.0
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.coordinate = coordinate
        self.installedDate = installedDate
        self.isActive = isActive
        self.coverageRadius = coverageRadius
    }
}
