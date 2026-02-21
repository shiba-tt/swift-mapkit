import SwiftUI
import MapKit

struct CrimeMapView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            // 危険エリアオーバーレイ（円）
            ForEach(viewModel.filteredDangerZones) { zone in
                MapCircle(center: zone.center, radius: zone.radius)
                    .foregroundStyle(zone.level.color.opacity(zone.level.opacity))
                    .stroke(zone.level.color.opacity(0.6), lineWidth: 2)
            }

            // 防犯カメラアノテーション
            ForEach(viewModel.filteredCameras) { camera in
                Annotation(camera.name, coordinate: camera.coordinate) {
                    CameraAnnotationView(camera: camera)
                        .onTapGesture {
                            viewModel.selectCamera(camera)
                        }
                }
            }

            // 犯罪発生アノテーション
            ForEach(viewModel.filteredCrimes) { crime in
                Annotation(crime.title, coordinate: crime.coordinate) {
                    CrimeAnnotationView(crime: crime)
                        .onTapGesture {
                            viewModel.selectCrime(crime)
                        }
                }
            }

            // 現在地表示
            UserAnnotation()
        }
        .mapStyle(.standard(pointsOfInterest: .including([.police, .hospital])))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
}

// MARK: - 犯罪アノテーションビュー
struct CrimeAnnotationView: View {
    let crime: CrimeIncident

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(crime.isResolved ? .gray : crime.severity.color)
                    .frame(width: 36, height: 36)
                    .shadow(color: (crime.isResolved ? Color.gray : crime.severity.color).opacity(0.5), radius: 4)

                Image(systemName: crime.type.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }

            // 三角形の矢印
            Triangle()
                .fill(crime.isResolved ? .gray : crime.severity.color)
                .frame(width: 12, height: 8)
        }
    }
}

// MARK: - カメラアノテーションビュー
struct CameraAnnotationView: View {
    let camera: SecurityCamera

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(camera.isActive ? camera.type.color : .gray)
                    .frame(width: 32, height: 32)
                    .shadow(color: camera.type.color.opacity(0.4), radius: 3)

                Image(systemName: camera.type.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Triangle()
                .fill(camera.isActive ? camera.type.color : .gray)
                .frame(width: 10, height: 6)
        }
        .opacity(camera.isActive ? 1.0 : 0.6)
    }
}

// MARK: - 三角形シェイプ
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

#Preview {
    CrimeMapView(viewModel: MapViewModel())
}
