import MapKit
import SwiftUI

// MARK: - Zone Map Overlay Identifiers

/// Associates a MapKit overlay with a game zone for rendering
final class ZoneCircleOverlay: MKCircle {
    var zoneID: UUID?
    var team: Team?
    var captureProgress: Double = 0
    var isBeingCaptured: Bool = false
}

final class ZonePolygonOverlay: MKPolygon {
    var zoneID: UUID?
    var team: Team?
    var captureProgress: Double = 0
    var isBeingCaptured: Bool = false
}

// MARK: - UIKit MapView Coordinator

struct GameMapViewRepresentable: UIViewRepresentable {
    let zones: [GameZone]
    let playerLocation: CLLocationCoordinate2D?
    let playerTeam: Team
    let currentZone: GameZone?
    var onZoneTapped: ((GameZone) -> Void)?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.mapType = .standard
        mapView.pointOfInterestFilter = .excludingAll

        if let location = playerLocation {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: 800,
                longitudinalMeters: 800
            )
            mapView.setRegion(region, animated: false)
        }

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.zones = zones
        context.coordinator.currentZone = currentZone
        context.coordinator.onZoneTapped = onZoneTapped

        // Remove existing overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        // Add zone overlays
        for zone in zones {
            switch zone.shape {
            case .circle(let center, let radius):
                let circle = ZoneCircleOverlay(
                    center: center.coordinate,
                    radius: radius
                )
                circle.zoneID = zone.id
                circle.team = zone.ownerTeam
                circle.captureProgress = zone.captureProgress
                circle.isBeingCaptured = zone.isBeingCaptured
                mapView.addOverlay(circle)

            case .polygon(let vertices):
                var coords = vertices.map { $0.coordinate }
                let polygon = ZonePolygonOverlay(
                    coordinates: &coords,
                    count: coords.count
                )
                polygon.zoneID = zone.id
                polygon.team = zone.ownerTeam
                polygon.captureProgress = zone.captureProgress
                polygon.isBeingCaptured = zone.isBeingCaptured
                mapView.addOverlay(polygon)
            }

            // Add zone label annotation
            let annotation = ZoneAnnotation(zone: zone)
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(zones: zones, currentZone: currentZone, onZoneTapped: onZoneTapped)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        var zones: [GameZone]
        var currentZone: GameZone?
        var onZoneTapped: ((GameZone) -> Void)?

        init(zones: [GameZone], currentZone: GameZone?, onZoneTapped: ((GameZone) -> Void)?) {
            self.zones = zones
            self.currentZone = currentZone
            self.onZoneTapped = onZoneTapped
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? ZoneCircleOverlay {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                configureRenderer(
                    renderer,
                    team: circleOverlay.team,
                    captureProgress: circleOverlay.captureProgress,
                    isBeingCaptured: circleOverlay.isBeingCaptured,
                    isCurrent: currentZone?.id == circleOverlay.zoneID
                )
                return renderer
            }

            if let polygonOverlay = overlay as? ZonePolygonOverlay {
                let renderer = MKPolygonRenderer(polygon: polygonOverlay)
                configureRenderer(
                    renderer,
                    team: polygonOverlay.team,
                    captureProgress: polygonOverlay.captureProgress,
                    isBeingCaptured: polygonOverlay.isBeingCaptured,
                    isCurrent: currentZone?.id == polygonOverlay.zoneID
                )
                return renderer
            }

            return MKOverlayRenderer(overlay: overlay)
        }

        private func configureRenderer(
            _ renderer: MKOverlayPathRenderer,
            team: Team?,
            captureProgress: Double,
            isBeingCaptured: Bool,
            isCurrent: Bool
        ) {
            if let team = team {
                renderer.fillColor = team.uiColor.withAlphaComponent(0.25 + CGFloat(captureProgress) * 0.15)
                renderer.strokeColor = team.uiColor.withAlphaComponent(0.9)
            } else {
                renderer.fillColor = UIColor.systemGray.withAlphaComponent(0.15)
                renderer.strokeColor = UIColor.systemGray.withAlphaComponent(0.5)
            }

            renderer.lineWidth = isCurrent ? 4 : 2

            if isBeingCaptured {
                renderer.lineDashPattern = [8, 4]
                renderer.strokeColor = UIColor.white.withAlphaComponent(0.9)
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let zoneAnnotation = annotation as? ZoneAnnotation else {
                return nil
            }

            let identifier = "ZoneAnnotation"
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            annotationView.annotation = annotation
            annotationView.canShowCallout = true

            let label = UILabel()
            label.text = zoneAnnotation.zone.name
            label.font = .boldSystemFont(ofSize: 11)
            label.textColor = .white
            label.textAlignment = .center
            label.backgroundColor = (zoneAnnotation.zone.ownerTeam?.uiColor ?? .systemGray).withAlphaComponent(0.85)
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            label.sizeToFit()
            label.frame = CGRect(
                x: 0, y: 0,
                width: label.frame.width + 16,
                height: label.frame.height + 8
            )

            annotationView.addSubview(label)
            annotationView.frame = label.frame
            annotationView.centerOffset = CGPoint(x: 0, y: -20)

            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let zoneAnnotation = annotation as? ZoneAnnotation else { return }
            onZoneTapped?(zoneAnnotation.zone)
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
}

// MARK: - Zone Annotation

final class ZoneAnnotation: NSObject, MKAnnotation {
    let zone: GameZone
    var coordinate: CLLocationCoordinate2D { zone.shape.centerCoordinate }
    var title: String? { zone.name }
    var subtitle: String? {
        if let team = zone.ownerTeam {
            return "\(team.displayName)が占領中 (\(zone.pointsValue)pt)"
        }
        return "中立ゾーン (\(zone.pointsValue)pt)"
    }

    init(zone: GameZone) {
        self.zone = zone
        super.init()
    }
}
