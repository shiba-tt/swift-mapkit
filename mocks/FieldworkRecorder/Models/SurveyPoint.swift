import Foundation
import SwiftData
import CoreLocation

@Model
final class SurveyPoint {
    var id: UUID
    var title: String
    var latitude: Double
    var longitude: Double
    var note: String
    var photoFileNames: [String]
    var createdAt: Date
    var category: String

    @Relationship(deleteRule: .nullify, inverse: \AreaBoundary.points)
    var boundary: AreaBoundary?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        title: String = "",
        latitude: Double,
        longitude: Double,
        note: String = "",
        category: String = "default"
    ) {
        self.id = UUID()
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.note = note
        self.photoFileNames = []
        self.createdAt = Date()
        self.category = category
    }
}

extension SurveyPoint {
    static let categories = [
        "default": "mappin",
        "flora": "leaf.fill",
        "fauna": "pawprint.fill",
        "geology": "mountain.2.fill",
        "water": "drop.fill",
        "structure": "building.2.fill"
    ]

    var categoryIcon: String {
        Self.categories[category] ?? "mappin"
    }
}
