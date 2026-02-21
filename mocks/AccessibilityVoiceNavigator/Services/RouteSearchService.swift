import Foundation
import MapKit
import Combine

/// MapKitの経路検索サービス
final class RouteSearchService: ObservableObject {
    @Published var searchResults: [SearchResultItem] = []
    @Published var isSearching = false

    private var searchCompleter = MKLocalSearchCompleter()
    private var searchTask: Task<Void, Never>?

    /// 地点を検索
    func searchPlaces(query: String, region: MKCoordinateRegion?) async -> [SearchResultItem] {
        guard !query.isEmpty else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest

        if let region = region {
            request.region = region
        }

        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            return response.mapItems.map { item in
                SearchResultItem(
                    name: item.name ?? "不明な場所",
                    address: formatAddress(item.placemark),
                    coordinate: item.placemark.coordinate,
                    mapItem: item
                )
            }
        } catch {
            return []
        }
    }

    /// 経路を検索（歩行経路を優先）
    func searchRoute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async throws -> [RouteInfo] {
        let request = MKDirections.Request()

        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .walking
        request.requestsAlternateRoutes = true

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        return response.routes.map { RouteInfo.from(route: $0) }
    }

    /// 到着予想時刻を取得
    func estimatedArrival(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async -> String? {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking

        let directions = MKDirections(request: request)

        do {
            let eta = try await directions.calculateETA()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "H時mm分"
            return formatter.string(from: eta.expectedArrivalDate)
        } catch {
            return nil
        }
    }

    /// 住所をフォーマット
    private func formatAddress(_ placemark: CLPlacemark) -> String {
        var components: [String] = []

        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let subLocality = placemark.subLocality {
            components.append(subLocality)
        }
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let subThoroughfare = placemark.subThoroughfare {
            components.append(subThoroughfare)
        }

        return components.isEmpty ? "住所不明" : components.joined()
    }
}
