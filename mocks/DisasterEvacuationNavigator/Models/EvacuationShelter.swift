import Foundation
import CoreLocation
import MapKit

/// 避難所の種別
enum ShelterType: String, CaseIterable, Identifiable, Codable {
    case earthquake = "地震"
    case flood = "洪水"
    case tsunami = "津波"
    case fire = "火災"
    case general = "一般"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .earthquake: return "waveform.path.ecg"
        case .flood: return "drop.fill"
        case .tsunami: return "water.waves"
        case .fire: return "flame.fill"
        case .general: return "building.2.fill"
        }
    }

    var color: String {
        switch self {
        case .earthquake: return "orange"
        case .flood: return "blue"
        case .tsunami: return "cyan"
        case .fire: return "red"
        case .general: return "green"
        }
    }
}

/// 避難所データモデル
struct EvacuationShelter: Identifiable, Equatable {
    let id: UUID
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let shelterTypes: [ShelterType]
    let capacity: Int
    let phoneNumber: String?
    let isOpen: Bool
    let note: String?

    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        coordinate: CLLocationCoordinate2D,
        shelterTypes: [ShelterType],
        capacity: Int,
        phoneNumber: String? = nil,
        isOpen: Bool = true,
        note: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.shelterTypes = shelterTypes
        self.capacity = capacity
        self.phoneNumber = phoneNumber
        self.isOpen = isOpen
        self.note = note
    }

    static func == (lhs: EvacuationShelter, rhs: EvacuationShelter) -> Bool {
        lhs.id == rhs.id
    }

    /// 現在地からの距離を計算
    func distance(from location: CLLocation) -> CLLocationDistance {
        let shelterLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distance(from: shelterLocation)
    }

    /// 距離を読みやすい文字列に変換
    func formattedDistance(from location: CLLocation) -> String {
        let dist = distance(from: location)
        if dist < 1000 {
            return String(format: "%.0fm", dist)
        } else {
            return String(format: "%.1fkm", dist / 1000)
        }
    }
}
