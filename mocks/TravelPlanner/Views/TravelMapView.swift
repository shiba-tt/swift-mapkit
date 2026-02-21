import SwiftUI
import MapKit

/// Main map view displaying routes color-coded by day with destination markers.
struct TravelMapView: View {
    @Bindable var viewModel: TravelPlanViewModel
    var dayPlans: [DayPlan]

    var body: some View {
        Map(position: $viewModel.mapCameraPosition, selection: $viewModel.selectedDestination) {
            // Draw routes for each day
            ForEach(dayPlans) { day in
                if let routes = viewModel.routeInfos[day.id] {
                    ForEach(routes) { routeInfo in
                        MapPolyline(routeInfo.route.polyline)
                            .stroke(day.color, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    }
                }
            }

            // Draw destination markers for each day
            ForEach(dayPlans) { day in
                ForEach(Array(day.destinations.enumerated()), id: \.element.id) { index, destination in
                    Annotation(
                        destination.name,
                        coordinate: destination.coordinate,
                        anchor: .bottom
                    ) {
                        DestinationMarkerView(
                            destination: destination,
                            dayNumber: day.dayNumber,
                            orderIndex: index + 1,
                            color: day.color,
                            isSelected: viewModel.selectedDestination == destination
                        )
                        .onTapGesture {
                            viewModel.selectDestination(destination)
                        }
                    }
                    .tag(destination)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
    }
}

/// A custom marker view for destination pins on the map.
struct DestinationMarkerView: View {
    let destination: Destination
    let dayNumber: Int
    let orderIndex: Int
    let color: Color
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: color.opacity(0.5), radius: isSelected ? 8 : 4)

                VStack(spacing: -2) {
                    Image(systemName: destination.category.systemImage)
                        .font(.system(size: isSelected ? 14 : 11))
                        .foregroundColor(.white)
                    Text("\(orderIndex)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // Triangle pointer
            Triangle()
                .fill(color)
                .frame(width: 12, height: 8)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

/// A simple triangle shape used as a pointer below map markers.
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
