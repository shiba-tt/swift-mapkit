import SwiftUI
import MapKit

/// MapKitを使用した配達地図ビュー。
/// ドライバーの位置、配達ルート、ウェイポイントをリアルタイム表示する。
struct DeliveryMapView: View {
    @EnvironmentObject var manager: DeliveryManager

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: DeliveryManager.centerCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )
    @State private var mapSelection: String?

    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
            // ドライバーのアノテーション
            ForEach(manager.drivers) { driver in
                Annotation(
                    driver.name,
                    coordinate: driver.coordinate,
                    anchor: .center
                ) {
                    DriverAnnotationView(
                        driver: driver,
                        isSelected: manager.selectedDriverID == driver.id
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            manager.selectDriver(driver.id)
                        }
                    }
                }
                .tag(driver.id.uuidString)
            }

            // 配達先マーカー
            ForEach(manager.deliveries.filter { $0.status != .delivered }) { delivery in
                // 集荷地点
                Annotation(
                    delivery.pickupAddress,
                    coordinate: delivery.pickupLocation,
                    anchor: .bottom
                ) {
                    WaypointMarkerView(type: .pickup, label: delivery.pickupAddress)
                }

                // 配達地点
                Annotation(
                    delivery.dropoffAddress,
                    coordinate: delivery.dropoffLocation,
                    anchor: .bottom
                ) {
                    WaypointMarkerView(type: .dropoff, label: delivery.dropoffAddress)
                }
            }

            // ルートのポリライン描画
            ForEach(manager.routes) { route in
                let isSelected = manager.selectedDriverID == route.driverID
                MapPolyline(coordinates: route.polylineCoordinates)
                    .stroke(
                        isSelected ? Color.blue : Color.blue.opacity(0.4),
                        style: StrokeStyle(
                            lineWidth: isSelected ? 4 : 2,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: route.isOptimized ? [] : [8, 4]
                        )
                    )
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.restaurant, .store])))
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
        .onChange(of: manager.selectedDriverID) { _, newID in
            if let id = newID, let driver = manager.drivers.first(where: { $0.id == id }) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: driver.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Driver Annotation View

struct DriverAnnotationView: View {
    let driver: Driver
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: isSelected ? 48 : 38, height: isSelected ? 48 : 38)

                Circle()
                    .fill(statusColor)
                    .frame(width: isSelected ? 36 : 28, height: isSelected ? 36 : 28)
                    .shadow(color: statusColor.opacity(0.5), radius: isSelected ? 6 : 3)

                Image(systemName: driver.vehicleType.systemImage)
                    .font(.system(size: isSelected ? 16 : 12, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(driver.heading - 90))
            }

            if isSelected {
                Text(driver.name)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.linear(duration: 1.5), value: driver.coordinate.latitude)
    }

    private var statusColor: Color {
        switch driver.status {
        case .idle: return .gray
        case .enRoute: return .blue
        case .delivering: return .orange
        case .returning: return .green
        }
    }
}

// MARK: - Waypoint Marker View

struct WaypointMarkerView: View {
    let type: DeliveryRoute.Waypoint.WaypointType
    let label: String

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(markerColor, in: Circle())
                .shadow(color: markerColor.opacity(0.4), radius: 2)

            // 三角形のピン
            Triangle()
                .fill(markerColor)
                .frame(width: 8, height: 5)
        }
    }

    private var iconName: String {
        switch type {
        case .pickup: return "arrow.up.circle"
        case .dropoff: return "mappin"
        case .warehouse: return "building.2"
        }
    }

    private var markerColor: Color {
        switch type {
        case .pickup: return .indigo
        case .dropoff: return .red
        case .warehouse: return .brown
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
