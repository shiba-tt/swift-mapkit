import SwiftUI
import MapKit

/// Displays route details for a selected day, including distance and travel time.
struct RouteDetailView: View {
    @Bindable var viewModel: TravelPlanViewModel
    let dayPlan: DayPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day header
            HStack {
                Circle()
                    .fill(dayPlan.color)
                    .frame(width: 12, height: 12)
                Text("Day \(dayPlan.dayNumber): \(dayPlan.title)")
                    .font(.headline)
                Spacer()
            }

            // Total summary
            if let routes = viewModel.routeInfos[dayPlan.id], !routes.isEmpty {
                HStack(spacing: 16) {
                    Label {
                        Text("合計: \(viewModel.selectedDayTotalDistance)")
                            .font(.subheadline.bold())
                    } icon: {
                        Image(systemName: "arrow.triangle.swap")
                            .foregroundStyle(dayPlan.color)
                    }

                    Label {
                        Text("移動時間: \(viewModel.selectedDayTotalTime)")
                            .font(.subheadline.bold())
                    } icon: {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(dayPlan.color)
                    }
                }
                .padding(.vertical, 4)
            }

            // Destination list with route info between them
            ForEach(Array(dayPlan.destinations.enumerated()), id: \.element.id) { index, destination in
                DestinationRow(
                    destination: destination,
                    orderIndex: index + 1,
                    color: dayPlan.color,
                    isSelected: viewModel.selectedDestination == destination,
                    onTap: {
                        viewModel.selectDestination(destination)
                    },
                    onLookAround: {
                        Task {
                            await viewModel.loadLookAround(for: destination)
                        }
                    },
                    isLoadingLookAround: viewModel.isLoadingLookAround && viewModel.selectedDestination == destination
                )

                // Route info between destinations
                if let routes = viewModel.routeInfos[dayPlan.id],
                   index < dayPlan.destinations.count - 1,
                   index < routes.count {
                    RouteSegmentView(routeInfo: routes[index], color: dayPlan.color)
                }
            }
        }
        .padding()
    }
}

/// A row displaying a single destination with actions.
struct DestinationRow: View {
    let destination: Destination
    let orderIndex: Int
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    let onLookAround: () -> Void
    let isLoadingLookAround: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Order badge
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                Text("\(orderIndex)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(destination.name)
                    .font(.subheadline.bold())
                HStack(spacing: 4) {
                    Image(systemName: destination.category.systemImage)
                        .font(.caption2)
                    Text(destination.category.rawValue)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Look Around button
            Button {
                onLookAround()
            } label: {
                if isLoadingLookAround {
                    ProgressView()
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "binoculars.fill")
                        .font(.body)
                        .foregroundStyle(color)
                        .frame(width: 32, height: 32)
                }
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? color.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

/// Displays route information between two destinations.
struct RouteSegmentView: View {
    let routeInfo: RouteInfo
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            // Vertical dashed line
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(width: 2, height: 30)
                .padding(.leading, 15)

            Image(systemName: "car.fill")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(routeInfo.distanceText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("•")
                .foregroundStyle(.secondary)

            Text(routeInfo.travelTimeText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}
