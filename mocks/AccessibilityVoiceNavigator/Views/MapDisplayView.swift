import SwiftUI
import MapKit

/// MapKitの地図表示ビュー（UIViewRepresentable）
struct MapDisplayView: UIViewRepresentable {
    @EnvironmentObject var viewModel: NavigationViewModel

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsCompass = true
        mapView.showsScale = true

        // アクセシビリティ設定
        mapView.accessibilityLabel = "ナビゲーション地図"
        mapView.accessibilityHint = "現在地と目的地への経路を表示"

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 経路のオーバーレイを更新
        mapView.removeOverlays(mapView.overlays)
        if let polyline = viewModel.routePolyline {
            mapView.addOverlay(polyline, level: .aboveRoads)
        }

        // 目的地のアノテーションを更新
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        if let destination = viewModel.selectedDestination {
            let annotation = DestinationAnnotation(
                coordinate: destination.coordinate,
                title: destination.name,
                subtitle: destination.address
            )
            mapView.addAnnotation(annotation)
        }

        // ナビゲーション中は現在地を追跡
        if viewModel.navigationState == .navigating {
            mapView.userTrackingMode = .followWithHeading
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapDisplayView

        init(_ parent: MapDisplayView) {
            self.parent = parent
        }

        // 経路のオーバーレイ描画
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 6
                renderer.lineDashPattern = nil
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        // 目的地のアノテーションビュー
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }

            let identifier = "DestinationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.markerTintColor = .systemRed
                annotationView?.glyphImage = UIImage(systemName: "mappin.circle.fill")
            } else {
                annotationView?.annotation = annotation
            }

            // アクセシビリティ
            annotationView?.accessibilityLabel = "目的地: \(annotation.title ?? "不明")"
            annotationView?.accessibilityHint = "目的地の位置を示すピン"

            return annotationView
        }
    }
}

/// 目的地アノテーション
final class DestinationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}
