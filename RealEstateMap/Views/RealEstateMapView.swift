import SwiftUI
import MapKit

/// 不動産マップメインビュー
struct RealEstateMapView: View {
    @State private var viewModel = MapViewModel()
    @State private var showFilterPanel = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // メインマップ
            Map(position: $viewModel.cameraPosition) {
                // 学区ポリゴン
                if viewModel.showSchoolDistricts {
                    SchoolDistrictOverlay(districts: viewModel.filteredSchoolDistricts)
                }

                // 駅徒歩圏サークル
                if viewModel.showStationCircles {
                    StationCircleOverlay(
                        stations: viewModel.stations,
                        walkingMinutes: viewModel.selectedWalkingMinutes
                    )
                }

                // 物件マーカー
                ForEach(viewModel.properties) { property in
                    Annotation(property.name, coordinate: property.coordinate) {
                        PropertyMarker(property: property)
                            .onTapGesture {
                                viewModel.selectProperty(property)
                            }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.school, .publicTransport])))
            .mapControls {
                MapCompass()
                MapScaleView()
                MapUserLocationButton()
            }

            // フィルタボタン
            VStack(spacing: 12) {
                // フィルタトグルボタン
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        showFilterPanel.toggle()
                    }
                } label: {
                    Image(systemName: showFilterPanel ? "xmark" : "slider.horizontal.3")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }

                // フィルタパネル
                if showFilterPanel {
                    FilterPanelView(viewModel: viewModel)
                        .frame(width: 280)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.top, 60)
            .padding(.trailing, 12)
        }
        // 物件詳細シート
        .sheet(isPresented: $viewModel.showPropertyDetail) {
            if let property = viewModel.selectedProperty {
                PropertyDetailView(
                    property: property,
                    onLookAround: {
                        Task {
                            await viewModel.requestLookAround(for: property.coordinate)
                        }
                    },
                    isLoadingLookAround: viewModel.isLoadingLookAround
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        // Look Around フルスクリーン
        .fullScreenCover(isPresented: $viewModel.showLookAround) {
            LookAroundPreviewView(
                scene: viewModel.lookAroundScene,
                propertyName: viewModel.selectedProperty?.name ?? "",
                onDismiss: {
                    viewModel.closeLookAround()
                }
            )
        }
    }
}

// MARK: - 物件マーカー

private struct PropertyMarker: View {
    let property: Property

    var body: some View {
        VStack(spacing: 0) {
            // 価格バッジ
            Text(property.priceText)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.red.gradient)
                )

            // ピン
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundStyle(.red)
                .padding(6)
                .background(
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                )

            // 三角形の先端
            Triangle()
                .fill(.white)
                .frame(width: 12, height: 8)
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
        }
    }
}

/// ピンの先端三角形
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    RealEstateMapView()
}
