import SwiftUI
import MapKit

@Observable
final class MapViewModel {
    // MARK: - Map State

    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6460, longitude: 139.7000),
            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        )
    )

    // MARK: - Filter State

    var showSchoolDistricts = true
    var showStationCircles = true
    var selectedSchoolLevel: SchoolDistrict.SchoolLevel? = nil
    var selectedWalkingMinutes: Int = 10

    // MARK: - Selection State

    var selectedProperty: Property?
    var showPropertyDetail = false
    var showLookAround = false

    // MARK: - Look Around

    var lookAroundScene: MKLookAroundScene?
    var isLoadingLookAround = false

    // MARK: - Data

    let properties = SampleData.properties
    let stations = SampleData.stations
    let schoolDistricts = SampleData.schoolDistricts

    // MARK: - Computed

    var filteredSchoolDistricts: [SchoolDistrict] {
        if let level = selectedSchoolLevel {
            return schoolDistricts.filter { $0.level == level }
        }
        return schoolDistricts
    }

    var walkingRadius: Double {
        Double(selectedWalkingMinutes) * 80.0
    }

    // MARK: - Actions

    func selectProperty(_ property: Property) {
        selectedProperty = property
        showPropertyDetail = true
    }

    @MainActor
    func requestLookAround(for coordinate: CLLocationCoordinate2D) async {
        isLoadingLookAround = true
        lookAroundScene = nil

        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        do {
            lookAroundScene = try await request.scene
            if lookAroundScene != nil {
                showLookAround = true
            }
        } catch {
            lookAroundScene = nil
        }
        isLoadingLookAround = false
    }

    func closeLookAround() {
        showLookAround = false
        lookAroundScene = nil
    }
}
