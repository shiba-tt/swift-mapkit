import Foundation
import MapKit

/// 競合店舗を表すモデル
struct Competitor: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let category: SearchCategory
    let address: String
    let phoneNumber: String?
    let url: URL?
    /// 分析中心点からの距離（メートル）
    let distance: CLLocationDistance

    init(
        id: UUID = UUID(),
        name: String,
        coordinate: CLLocationCoordinate2D,
        category: SearchCategory,
        address: String,
        phoneNumber: String? = nil,
        url: URL? = nil,
        distance: CLLocationDistance
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.category = category
        self.address = address
        self.phoneNumber = phoneNumber
        self.url = url
        self.distance = distance
    }

    /// MKMapItemから競合店舗を生成
    init(from mapItem: MKMapItem, center: CLLocationCoordinate2D, category: SearchCategory) {
        self.id = UUID()
        self.name = mapItem.name ?? "不明"
        self.coordinate = mapItem.placemark.coordinate
        self.category = category
        self.address = Self.formatAddress(from: mapItem.placemark)
        self.phoneNumber = mapItem.phoneNumber
        self.url = mapItem.url

        let centerLocation = CLLocation(
            latitude: center.latitude,
            longitude: center.longitude
        )
        let itemLocation = CLLocation(
            latitude: mapItem.placemark.coordinate.latitude,
            longitude: mapItem.placemark.coordinate.longitude
        )
        self.distance = centerLocation.distance(from: itemLocation)
    }

    /// 距離を読みやすい形式にフォーマット
    var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.1f km", distance / 1000)
        }
        return String(format: "%.0f m", distance)
    }

    /// 日本式住所フォーマット
    private static func formatAddress(from placemark: MKPlacemark) -> String {
        let components = [
            placemark.administrativeArea,
            placemark.locality,
            placemark.thoroughfare,
            placemark.subThoroughfare,
        ].compactMap { $0 }

        return components.isEmpty ? "住所不明" : components.joined()
    }

    static func == (lhs: Competitor, rhs: Competitor) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
