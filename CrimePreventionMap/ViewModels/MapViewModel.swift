import Foundation
import CoreLocation
import MapKit
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - Map State
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671), // 東京駅
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )

    // MARK: - Data
    @Published var crimeIncidents: [CrimeIncident] = SampleData.crimeIncidents
    @Published var securityCameras: [SecurityCamera] = SampleData.securityCameras
    @Published var dangerZones: [DangerZone] = SampleData.dangerZones

    // MARK: - Filter State
    @Published var showCrimes: Bool = true
    @Published var showCameras: Bool = true
    @Published var showDangerZones: Bool = true
    @Published var showResolvedCrimes: Bool = false

    @Published var selectedCrimeTypes: Set<CrimeType> = Set(CrimeType.allCases)
    @Published var selectedCameraTypes: Set<CameraType> = Set(CameraType.allCases)
    @Published var minimumDangerLevel: DangerLevel = .caution
    @Published var minimumSeverity: CrimeIncident.Severity = .low

    // MARK: - Selection State
    @Published var selectedCrime: CrimeIncident?
    @Published var selectedCamera: SecurityCamera?
    @Published var selectedDangerZone: DangerZone?
    @Published var showingDetail: Bool = false
    @Published var showingFilter: Bool = false

    // MARK: - Stats
    @Published var showingStats: Bool = false

    // MARK: - Filtered Data
    var filteredCrimes: [CrimeIncident] {
        crimeIncidents.filter { crime in
            guard showCrimes else { return false }
            guard selectedCrimeTypes.contains(crime.type) else { return false }
            guard crime.severity >= minimumSeverity else { return false }
            if !showResolvedCrimes && crime.isResolved { return false }
            return true
        }
    }

    var filteredCameras: [SecurityCamera] {
        guard showCameras else { return [] }
        return securityCameras.filter { camera in
            selectedCameraTypes.contains(camera.type)
        }
    }

    var filteredDangerZones: [DangerZone] {
        guard showDangerZones else { return [] }
        return dangerZones.filter { zone in
            zone.level >= minimumDangerLevel
        }
    }

    // MARK: - Statistics
    var totalCrimes: Int { crimeIncidents.count }
    var unresolvedCrimes: Int { crimeIncidents.filter { !$0.isResolved }.count }
    var totalCameras: Int { securityCameras.count }
    var activeCameras: Int { securityCameras.filter { $0.isActive }.count }
    var dangerAreaCount: Int { dangerZones.filter { $0.level >= .warning }.count }

    var crimesByType: [(CrimeType, Int)] {
        CrimeType.allCases.compactMap { type in
            let count = crimeIncidents.filter { $0.type == type }.count
            return count > 0 ? (type, count) : nil
        }.sorted { $0.1 > $1.1 }
    }

    // MARK: - Actions
    func selectCrime(_ crime: CrimeIncident) {
        selectedCrime = crime
        selectedCamera = nil
        selectedDangerZone = nil
        showingDetail = true
    }

    func selectCamera(_ camera: SecurityCamera) {
        selectedCamera = camera
        selectedCrime = nil
        selectedDangerZone = nil
        showingDetail = true
    }

    func selectDangerZone(_ zone: DangerZone) {
        selectedDangerZone = zone
        selectedCrime = nil
        selectedCamera = nil
        showingDetail = true
    }

    func clearSelection() {
        selectedCrime = nil
        selectedCamera = nil
        selectedDangerZone = nil
        showingDetail = false
    }

    func moveToLocation(_ coordinate: CLLocationCoordinate2D) {
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }

    func resetFilters() {
        showCrimes = true
        showCameras = true
        showDangerZones = true
        showResolvedCrimes = false
        selectedCrimeTypes = Set(CrimeType.allCases)
        selectedCameraTypes = Set(CameraType.allCases)
        minimumDangerLevel = .caution
        minimumSeverity = .low
    }

    // MARK: - Date Formatting
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
