import Foundation
import SwiftData
import CoreLocation

@Model
final class AreaBoundary {
    var id: UUID
    var name: String
    var coordinateLatitudes: [Double]
    var coordinateLongitudes: [Double]
    var colorHex: String
    var note: String
    var createdAt: Date

    var points: [SurveyPoint]?

    var coordinates: [CLLocationCoordinate2D] {
        get {
            zip(coordinateLatitudes, coordinateLongitudes).map {
                CLLocationCoordinate2D(latitude: $0, longitude: $1)
            }
        }
        set {
            coordinateLatitudes = newValue.map(\.latitude)
            coordinateLongitudes = newValue.map(\.longitude)
        }
    }

    init(
        name: String = "",
        coordinates: [CLLocationCoordinate2D] = [],
        colorHex: String = "#FF6B6B",
        note: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.coordinateLatitudes = coordinates.map(\.latitude)
        self.coordinateLongitudes = coordinates.map(\.longitude)
        self.colorHex = colorHex
        self.note = note
        self.createdAt = Date()
    }
}
