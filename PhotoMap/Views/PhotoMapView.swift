import SwiftUI
import MapKit

/// MapKitを使用したフォトマップ表示
struct PhotoMapView: View {
    @ObservedObject var viewModel: PhotoMapViewModel

    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            // 写真アノテーション
            ForEach(viewModel.photos) { photo in
                Annotation(
                    "",
                    coordinate: photo.coordinate,
                    anchor: .bottom
                ) {
                    PhotoAnnotationView(
                        photo: photo,
                        showOrder: viewModel.showRoute
                    ) {
                        viewModel.selectPhoto(photo)
                    }
                }
            }

            // 撮影ルートのポリライン
            if viewModel.showRoute && viewModel.routeCoordinates.count >= 2 {
                MapPolyline(coordinates: viewModel.routeCoordinates)
                    .stroke(
                        .linearGradient(
                            colors: [.blue, .cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 3,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: [8, 4]
                        )
                    )
            }

            // ユーザーの現在位置
            UserAnnotation()
        }
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
        .mapStyle(.standard(elevation: .realistic))
    }
}
