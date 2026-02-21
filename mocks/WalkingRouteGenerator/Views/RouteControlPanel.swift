import CoreLocation
import SwiftUI

struct RouteControlPanel: View {
    @ObservedObject var viewModel: RouteViewModel

    var body: some View {
        VStack(spacing: 12) {
            dragIndicator

            if let route = viewModel.route {
                RouteInfoBar(route: route)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            distanceSlider
            actionButtons
        }
        .padding(.vertical)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }

    // MARK: - Sub-views

    private var dragIndicator: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.4))
            .frame(width: 36, height: 5)
    }

    private var distanceSlider: some View {
        VStack(spacing: 4) {
            Text("散歩距離: \(distanceLabel)")
                .font(.headline)

            Slider(
                value: $viewModel.desiredDistance,
                in: 500...10_000,
                step: 100
            )
            .tint(.blue)

            HStack {
                Text("500m").font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Text("10km").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            if viewModel.route != nil {
                Button {
                    viewModel.clearRoute()
                } label: {
                    Label("クリア", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Button {
                Task { await viewModel.generateRoute() }
            } label: {
                Group {
                    if viewModel.isGenerating {
                        ProgressView()
                    } else {
                        Label(
                            viewModel.route == nil ? "ルート生成" : "再生成",
                            systemImage: "figure.walk"
                        )
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isGenerating)
        }
        .padding(.horizontal)
    }

    private var distanceLabel: String {
        if viewModel.desiredDistance >= 1000 {
            return String(format: "%.1f km", viewModel.desiredDistance / 1000)
        }
        return String(format: "%.0f m", viewModel.desiredDistance)
    }
}

// MARK: - Route Info

private struct RouteInfoBar: View {
    let route: WalkingRoute

    var body: some View {
        HStack(spacing: 20) {
            infoItem(
                icon: "map",
                iconColor: .blue,
                value: formatDistance(route.totalDistance),
                label: "距離"
            )

            Divider().frame(height: 40)

            infoItem(
                icon: "clock",
                iconColor: .orange,
                value: formatTime(route.estimatedTime),
                label: "所要時間"
            )
        }
        .padding(.horizontal)
    }

    private func infoItem(
        icon: String, iconColor: Color, value: String, label: String
    ) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func formatDistance(_ meters: CLLocationDistance) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        }
        return String(format: "%.0f m", meters)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes >= 60 {
            return "\(minutes / 60)時間\(minutes % 60)分"
        }
        return "\(minutes)分"
    }
}

#Preview {
    RouteControlPanel(viewModel: RouteViewModel())
}
