import SwiftUI
import MapKit

/// メインマップビュー - 避難所・ルート・浸水想定区域を表示
struct EvacuationMapView: View {
    @ObservedObject var viewModel: EvacuationViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapSelection: EvacuationShelter?

    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
            // 現在地
            UserAnnotation()

            // 浸水想定区域（MapCircle）
            if viewModel.showFloodZones {
                ForEach(viewModel.floodZones) { zone in
                    MapCircle(center: zone.center, radius: zone.radius)
                        .foregroundStyle(zone.depthLevel.color)
                        .stroke(zone.depthLevel.strokeColor, lineWidth: 1.5)
                }
            }

            // ルート表示
            if let route = viewModel.route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 5)
            }

            // 避難所マーカー
            ForEach(viewModel.filteredShelters) { shelter in
                Annotation(
                    shelter.name,
                    coordinate: shelter.coordinate,
                    anchor: .bottom
                ) {
                    ShelterAnnotationView(
                        shelter: shelter,
                        isSelected: viewModel.selectedShelter == shelter
                    )
                }
                .tag(shelter)
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onChange(of: mapSelection) { _, newValue in
            if let shelter = newValue {
                viewModel.selectShelter(shelter)
            }
        }
        .onChange(of: viewModel.selectedShelter) { _, newValue in
            if let shelter = newValue {
                withAnimation(.easeInOut(duration: 0.5)) {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: shelter.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    ))
                }
            }
        }
        .onAppear {
            cameraPosition = .region(viewModel.initialRegion)
        }
    }
}

/// 避難所アノテーション表示
struct ShelterAnnotationView: View {
    let shelter: EvacuationShelter
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.red : (shelter.isOpen ? Color.green : Color.gray))
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(radius: isSelected ? 4 : 2)

                Image(systemName: primaryIcon)
                    .font(isSelected ? .title3 : .body)
                    .foregroundStyle(.white)
            }

            // 選択時に名前を表示
            if isSelected {
                Text(shelter.name)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .offset(y: 2)
            }

            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundStyle(isSelected ? Color.red : (shelter.isOpen ? Color.green : Color.gray))
                .rotationEffect(.degrees(180))
                .offset(y: -3)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }

    private var primaryIcon: String {
        shelter.shelterTypes.first?.iconName ?? "building.2.fill"
    }
}
