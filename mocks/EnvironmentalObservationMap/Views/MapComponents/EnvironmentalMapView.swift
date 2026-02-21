import SwiftUI
import MapKit

/// UIViewRepresentable wrapper for MKMapView with custom overlays and annotations
struct EnvironmentalMapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = viewModel.initialRegion
        mapView.showsUserLocation = false
        mapView.mapType = .standard
        mapView.pointOfInterestFilter = .some(MKPointOfInterestFilter(excluding: []))
        mapView.showsBuildings = true

        // Register annotation views
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: "ParkAnnotation"
        )
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: "TreeAnnotation"
        )

        updateOverlaysAndAnnotations(on: mapView)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        updateOverlaysAndAnnotations(on: mapView)
    }

    // MARK: - Update Logic

    private func updateOverlaysAndAnnotations(on mapView: MKMapView) {
        // Remove existing overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        // Add park polygon overlays
        if viewModel.layerVisibility.showParks {
            for park in viewModel.parks {
                let polygon = park.toPolygon()
                mapView.addOverlay(polygon, level: .aboveRoads)

                let annotation = ParkAnnotation(park: park)
                mapView.addAnnotation(annotation)
            }
        }

        // Add street tree annotations
        if viewModel.layerVisibility.showStreetTrees {
            for tree in viewModel.streetTrees {
                let annotation = TreeAnnotation(tree: tree)
                mapView.addAnnotation(annotation)
            }
        }

        // Add heatmap overlay
        if viewModel.layerVisibility.showHeatmap {
            let heatmapPoints = viewModel.heatmapValues.map { value in
                HeatmapOverlay.DataPoint(
                    coordinate: value.coordinate,
                    intensity: value.intensity
                )
            }
            if !heatmapPoints.isEmpty {
                let overlay = HeatmapOverlay(
                    dataPoints: heatmapPoints,
                    radius: 400,
                    dataType: viewModel.layerVisibility.heatmapType
                )
                mapView.addOverlay(overlay, level: .aboveLabels)
            }
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        let viewModel: MapViewModel

        init(viewModel: MapViewModel) {
            self.viewModel = viewModel
        }

        // MARK: Overlay Rendering

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let heatmap = overlay as? HeatmapOverlay {
                return HeatmapOverlayRenderer(overlay: heatmap)
            }

            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.2)
                renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.7)
                renderer.lineWidth = 2
                return renderer
            }

            return MKOverlayRenderer(overlay: overlay)
        }

        // MARK: Annotation Views

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let parkAnnotation = annotation as? ParkAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: "ParkAnnotation",
                    for: annotation
                ) as! MKMarkerAnnotationView
                view.glyphImage = UIImage(systemName: "leaf.fill")
                view.markerTintColor = .systemGreen
                view.titleVisibility = .adaptive
                view.subtitleVisibility = .adaptive
                view.canShowCallout = true

                let button = UIButton(type: .detailDisclosure)
                view.rightCalloutAccessoryView = button

                return view
            }

            if let treeAnnotation = annotation as? TreeAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: "TreeAnnotation",
                    for: annotation
                ) as! MKMarkerAnnotationView
                view.glyphImage = UIImage(systemName: "tree.fill")
                view.displayPriority = .defaultLow
                view.canShowCallout = true

                switch treeAnnotation.tree.healthStatus {
                case .excellent:
                    view.markerTintColor = UIColor.systemGreen
                case .good:
                    view.markerTintColor = UIColor.systemBlue
                case .fair:
                    view.markerTintColor = UIColor.systemOrange
                case .poor:
                    view.markerTintColor = UIColor.systemRed
                }

                let button = UIButton(type: .detailDisclosure)
                view.rightCalloutAccessoryView = button

                return view
            }

            return nil
        }

        // MARK: Callout Accessory Tapped

        func mapView(
            _ mapView: MKMapView,
            annotationView view: MKAnnotationView,
            calloutAccessoryControlTapped control: UIControl
        ) {
            if let parkAnnotation = view.annotation as? ParkAnnotation {
                Task { @MainActor in
                    viewModel.selectPark(parkAnnotation.park)
                }
            } else if let treeAnnotation = view.annotation as? TreeAnnotation {
                Task { @MainActor in
                    viewModel.selectTree(treeAnnotation.tree)
                }
            }
        }
    }
}
