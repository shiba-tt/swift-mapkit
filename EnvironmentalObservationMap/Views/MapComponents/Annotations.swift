import Foundation
import MapKit

// MARK: - Park Annotation

/// Map annotation representing a park location
final class ParkAnnotation: NSObject, MKAnnotation {
    let park: ParkRegion
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(park: ParkRegion) {
        self.park = park
        self.coordinate = park.center
        self.title = park.name
        self.subtitle = "樹木数: \(park.treeCount.formatted())本"
        super.init()
    }
}

// MARK: - Tree Annotation

/// Map annotation representing a street tree
final class TreeAnnotation: NSObject, MKAnnotation {
    let tree: StreetTree
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(tree: StreetTree) {
        self.tree = tree
        self.coordinate = tree.coordinate
        self.title = tree.speciesJapanese
        self.subtitle = "樹高: \(String(format: "%.1f", tree.height))m / \(tree.healthStatus.rawValue)"
        super.init()
    }
}
