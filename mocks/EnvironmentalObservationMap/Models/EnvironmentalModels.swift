import Foundation
import CoreLocation
import MapKit

// MARK: - Environmental Data Point

/// A single environmental measurement at a specific location
struct EnvironmentalDataPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let airQualityIndex: Double   // 0–500 (AQI scale)
    let noiseLevel: Double        // 0–120 (dB scale)

    /// Normalized air quality value (0.0 = good, 1.0 = hazardous)
    var normalizedAirQuality: Double {
        min(max(airQualityIndex / 300.0, 0), 1)
    }

    /// Normalized noise level (0.0 = quiet, 1.0 = very loud)
    var normalizedNoiseLevel: Double {
        min(max(noiseLevel / 100.0, 0), 1)
    }
}

// MARK: - Park Region

/// A park area defined by a polygon of coordinates
struct ParkRegion: Identifiable {
    let id = UUID()
    let name: String
    let center: CLLocationCoordinate2D
    let coordinates: [CLLocationCoordinate2D]
    let area: Double              // approximate area in m²
    let treeCount: Int
    let description: String

    /// Creates an MKPolygon overlay from the park coordinates
    func toPolygon() -> MKPolygon {
        var coords = coordinates
        return MKPolygon(coordinates: &coords, count: coords.count)
    }
}

// MARK: - Street Tree

/// A single street tree at a specific location
struct StreetTree: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let species: String
    let height: Double            // meters
    let trunkDiameter: Double     // centimeters
    let healthStatus: TreeHealthStatus

    var speciesJapanese: String {
        Self.speciesNameMap[species] ?? species
    }

    private static let speciesNameMap: [String: String] = [
        "Ginkgo": "イチョウ",
        "Cherry": "サクラ",
        "Zelkova": "ケヤキ",
        "Camphor": "クスノキ",
        "Japanese Cedar": "スギ",
        "Maple": "カエデ",
        "Pine": "マツ",
        "Magnolia": "モクレン",
        "Dogwood": "ハナミズキ",
        "Camellia": "ツバキ"
    ]
}

enum TreeHealthStatus: String, CaseIterable {
    case excellent = "良好"
    case good = "普通"
    case fair = "注意"
    case poor = "不良"

    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "orange"
        case .poor: return "red"
        }
    }
}

// MARK: - Heatmap Data Type

/// The type of environmental data displayed in the heatmap
enum HeatmapDataType: String, CaseIterable {
    case airQuality = "空気質"
    case noise = "騒音"

    var unit: String {
        switch self {
        case .airQuality: return "AQI"
        case .noise: return "dB"
        }
    }

    var gradientDescription: String {
        switch self {
        case .airQuality: return "良好 → 不良"
        case .noise: return "静か → うるさい"
        }
    }
}

// MARK: - Map Layer Visibility

/// Controls which layers are visible on the map
struct MapLayerVisibility {
    var showParks: Bool = true
    var showStreetTrees: Bool = true
    var showHeatmap: Bool = true
    var heatmapType: HeatmapDataType = .airQuality
}
