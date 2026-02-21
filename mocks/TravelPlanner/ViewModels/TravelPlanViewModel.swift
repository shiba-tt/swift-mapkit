import Foundation
import MapKit
import SwiftUI
import Observation

/// ViewModel managing the travel plan state, route calculations, and map interactions.
@Observable
final class TravelPlanViewModel {
    var travelPlan: TravelPlan?
    var selectedDayPlan: DayPlan?
    var selectedDestination: Destination?
    var routeInfos: [UUID: [RouteInfo]] = [:]
    var isCalculatingRoutes = false
    var mapCameraPosition: MapCameraPosition = .automatic
    var showLookAround = false
    var lookAroundScene: MKLookAroundScene?
    var isLoadingLookAround = false
    var lookAroundError: String?

    // Summary for selected day
    var selectedDayTotalDistance: String {
        guard let day = selectedDayPlan,
              let routes = routeInfos[day.id] else { return "—" }
        let total = routes.reduce(0.0) { $0 + $1.distance }
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(fromDistance: total)
    }

    var selectedDayTotalTime: String {
        guard let day = selectedDayPlan,
              let routes = routeInfos[day.id] else { return "—" }
        let total = routes.reduce(0.0) { $0 + $1.expectedTravelTime }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }

    /// Loads a travel plan and calculates all routes.
    func loadPlan(_ plan: TravelPlan) {
        self.travelPlan = plan
        if let firstDay = plan.dayPlans.first {
            self.selectedDayPlan = firstDay
        }
        Task {
            await calculateAllRoutes()
        }
    }

    /// Selects a day plan and updates the camera to show all destinations.
    func selectDay(_ day: DayPlan) {
        selectedDayPlan = day
        selectedDestination = nil
        focusCameraOnDay(day)
    }

    /// Selects a destination and optionally loads Look Around.
    func selectDestination(_ destination: Destination) {
        selectedDestination = destination
        let coordinate = destination.coordinate
        mapCameraPosition = .camera(
            MapCamera(centerCoordinate: coordinate, distance: 1000, heading: 0, pitch: 60)
        )
    }

    /// Calculates routes for all day plans.
    func calculateAllRoutes() async {
        guard let plan = travelPlan else { return }
        isCalculatingRoutes = true

        for day in plan.dayPlans {
            let routes = await calculateRoutesForDay(day)
            await MainActor.run {
                routeInfos[day.id] = routes
            }
        }

        await MainActor.run {
            isCalculatingRoutes = false
        }
    }

    /// Calculates routes for a single day plan.
    private func calculateRoutesForDay(_ day: DayPlan) async -> [RouteInfo] {
        var routes: [RouteInfo] = []
        let destinations = day.destinations

        guard destinations.count >= 2 else { return routes }

        for i in 0..<(destinations.count - 1) {
            let from = destinations[i]
            let to = destinations[i + 1]

            let request = MKDirections.Request()
            request.source = MKMapItem(
                placemark: MKPlacemark(coordinate: from.coordinate)
            )
            request.destination = MKMapItem(
                placemark: MKPlacemark(coordinate: to.coordinate)
            )
            request.transportType = .automobile

            let directions = MKDirections(request: request)
            do {
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    routes.append(RouteInfo(from: from, to: to, route: route))
                }
            } catch {
                print("Route calculation error from \(from.name) to \(to.name): \(error)")
            }
        }

        return routes
    }

    /// Loads the Look Around scene for a destination.
    func loadLookAround(for destination: Destination) async {
        await MainActor.run {
            isLoadingLookAround = true
            lookAroundError = nil
            lookAroundScene = nil
        }

        let request = MKLookAroundSceneRequest(coordinate: destination.coordinate)
        do {
            let scene = try await request.scene
            await MainActor.run {
                self.lookAroundScene = scene
                self.isLoadingLookAround = false
                if scene == nil {
                    self.lookAroundError = "この場所ではLook Aroundを利用できません"
                } else {
                    self.showLookAround = true
                }
            }
        } catch {
            await MainActor.run {
                self.isLoadingLookAround = false
                self.lookAroundError = "Look Aroundの読み込みに失敗しました"
            }
        }
    }

    /// Focuses the camera to show all destinations in the selected day.
    func focusCameraOnDay(_ day: DayPlan) {
        guard !day.destinations.isEmpty else { return }

        let coordinates = day.destinations.map { $0.coordinate }
        let minLat = coordinates.map(\.latitude).min()!
        let maxLat = coordinates.map(\.latitude).max()!
        let minLon = coordinates.map(\.longitude).min()!
        let maxLon = coordinates.map(\.longitude).max()!

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5 + 0.01,
            longitudeDelta: (maxLon - minLon) * 1.5 + 0.01
        )
        mapCameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }

    /// Focuses the camera to show all days.
    func focusCameraOnAllDays() {
        guard let plan = travelPlan else { return }
        let allDestinations = plan.dayPlans.flatMap(\.destinations)
        guard !allDestinations.isEmpty else { return }

        let coordinates = allDestinations.map { $0.coordinate }
        let minLat = coordinates.map(\.latitude).min()!
        let maxLat = coordinates.map(\.latitude).max()!
        let minLon = coordinates.map(\.longitude).min()!
        let maxLon = coordinates.map(\.longitude).max()!

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5 + 0.01,
            longitudeDelta: (maxLon - minLon) * 1.5 + 0.01
        )
        mapCameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
}
