import Foundation
import CoreLocation
import MapKit

/// A single destination point within a day's travel plan.
struct Destination: Identifiable, Hashable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let category: Category

    init(
        id: UUID = UUID(),
        name: String,
        coordinate: CLLocationCoordinate2D,
        category: Category = .sightseeing
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.category = category
    }

    enum Category: String, CaseIterable {
        case sightseeing = "目についた場所"
        case restaurant = "レストラン"
        case hotel = "ホテル"
        case shopping = "ショッピング"
        case nature = "自然"
        case temple = "寺社仏閣"

        var systemImage: String {
            switch self {
            case .sightseeing: return "binoculars.fill"
            case .restaurant: return "fork.knife"
            case .hotel: return "bed.double.fill"
            case .shopping: return "bag.fill"
            case .nature: return "leaf.fill"
            case .temple: return "building.columns.fill"
            }
        }
    }

    static func == (lhs: Destination, rhs: Destination) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
