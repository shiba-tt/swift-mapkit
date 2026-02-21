import SwiftUI
import MapKit

/// MKMapViewをラップしたSwiftUI用交通地図ビュー
struct TrafficMapView: UIViewRepresentable {
    let routes: [TrafficRoute]
    let congestionPoints: [CongestionPoint]
    let showTrafficLayer: Bool
    let region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsTraffic = showTrafficLayer
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.mapType = .standard
        mapView.setRegion(region, animated: false)
        mapView.pointOfInterestFilter = .includingAll
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 交通レイヤーの表示切替
        mapView.showsTraffic = showTrafficLayer

        // 既存のオーバーレイとアノテーションをクリア
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        // ルートのポリラインを追加
        for route in routes {
            for segment in route.segments {
                let polyline = segment.polyline()
                mapView.addOverlay(polyline, level: .aboveRoads)
            }
        }

        // 渋滞ポイントのアノテーションを追加
        for point in congestionPoints {
            let annotation = CongestionAnnotation(congestionPoint: point)
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {

        // ポリラインのレンダリング
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? TrafficPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = polyline.trafficLevel.color
                renderer.lineWidth = 6.0
                renderer.lineCap = .round
                renderer.lineJoin = .round
                renderer.alpha = 0.85
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        // アノテーションビューのカスタマイズ
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let congestionAnnotation = annotation as? CongestionAnnotation else {
                return nil
            }

            let identifier = "CongestionPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: congestionAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                // コールアウトに詳細ラベルを追加
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.font = .systemFont(ofSize: 12)
                annotationView?.detailCalloutAccessoryView = detailLabel
            } else {
                annotationView?.annotation = congestionAnnotation
            }

            // 渋滞レベルに応じた色とグリフ
            let level = congestionAnnotation.trafficLevel
            annotationView?.markerTintColor = level.color
            annotationView?.glyphImage = UIImage(systemName: level.icon)

            // 詳細ラベルを更新
            if let detailLabel = annotationView?.detailCalloutAccessoryView as? UILabel {
                detailLabel.text = """
                \(congestionAnnotation.congestionDescription)
                渋滞レベル: \(level.displayName)
                推定速度: \(level.estimatedSpeed) km/h
                """
            }

            return annotationView
        }
    }
}

// MARK: - カスタムアノテーション

/// 渋滞ポイント用アノテーション
final class CongestionAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let trafficLevel: TrafficLevel
    let congestionDescription: String

    init(congestionPoint: CongestionPoint) {
        self.coordinate = congestionPoint.coordinate
        self.title = congestionPoint.roadName
        self.subtitle = congestionPoint.trafficLevel.displayName
        self.trafficLevel = congestionPoint.trafficLevel
        self.congestionDescription = congestionPoint.description
        super.init()
    }
}
