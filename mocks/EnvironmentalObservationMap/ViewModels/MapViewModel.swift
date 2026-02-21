import Foundation
import CoreLocation
import MapKit
import Combine

/// ViewModel managing the environmental observation map state
@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var layerVisibility = MapLayerVisibility()
    @Published var selectedPark: ParkRegion?
    @Published var selectedTree: StreetTree?
    @Published var showDetailSheet = false

    // MARK: - Data

    let parks: [ParkRegion] = SampleDataProvider.parks
    let streetTrees: [StreetTree] = SampleDataProvider.streetTrees
    let environmentalData: [EnvironmentalDataPoint] = SampleDataProvider.environmentalData

    // MARK: - Map Configuration

    /// Initial map region centered on Shinjuku, Tokyo
    let initialRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6862, longitude: 139.7050),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )

    // MARK: - Computed Properties

    /// Park polygon overlays to display on the map
    var parkOverlays: [MKPolygon] {
        guard layerVisibility.showParks else { return [] }
        return parks.map { $0.toPolygon() }
    }

    /// Current heatmap data points filtered by the selected type
    var heatmapValues: [(coordinate: CLLocationCoordinate2D, intensity: Double)] {
        guard layerVisibility.showHeatmap else { return [] }
        return environmentalData.map { point in
            let intensity: Double
            switch layerVisibility.heatmapType {
            case .airQuality:
                intensity = point.normalizedAirQuality
            case .noise:
                intensity = point.normalizedNoiseLevel
            }
            return (coordinate: point.coordinate, intensity: intensity)
        }
    }

    // MARK: - Actions

    func selectPark(_ park: ParkRegion) {
        selectedTree = nil
        selectedPark = park
        showDetailSheet = true
    }

    func selectTree(_ tree: StreetTree) {
        selectedPark = nil
        selectedTree = tree
        showDetailSheet = true
    }

    func dismissDetail() {
        showDetailSheet = false
        selectedPark = nil
        selectedTree = nil
    }

    func toggleLayer(_ keyPath: WritableKeyPath<MapLayerVisibility, Bool>) {
        layerVisibility[keyPath: keyPath].toggle()
    }

    func setHeatmapType(_ type: HeatmapDataType) {
        layerVisibility.heatmapType = type
    }

    // MARK: - Data Lookup

    /// Find the closest environmental data point to a given coordinate
    func closestDataPoint(to coordinate: CLLocationCoordinate2D) -> EnvironmentalDataPoint? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return environmentalData.min(by: { a, b in
            let distA = CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
                .distance(from: location)
            let distB = CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude)
                .distance(from: location)
            return distA < distB
        })
    }

    /// Find the park containing a given polygon overlay
    func park(for polygon: MKPolygon) -> ParkRegion? {
        let overlays = parkOverlays
        guard let index = overlays.firstIndex(where: { $0 === polygon }) else { return nil }
        return parks[index]
    }
}
