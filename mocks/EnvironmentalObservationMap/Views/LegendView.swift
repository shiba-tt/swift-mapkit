import SwiftUI

/// Legend view displaying the heatmap color scale
struct LegendView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        if viewModel.layerVisibility.showHeatmap {
            VStack(alignment: .leading, spacing: 6) {
                // Title
                HStack(spacing: 4) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.caption2)
                    Text(viewModel.layerVisibility.heatmapType.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.primary)

                // Gradient bar
                HStack(spacing: 0) {
                    gradientBar
                        .frame(width: 120, height: 14)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }

                // Labels
                HStack {
                    Text(lowLabel)
                        .font(.system(size: 9))
                    Spacer()
                    Text(highLabel)
                        .font(.system(size: 9))
                }
                .frame(width: 120)
                .foregroundStyle(.secondary)

                // Unit and description
                Text(viewModel.layerVisibility.heatmapType.gradientDescription)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)

                // Annotation legend
                Divider()

                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 9))
                    Text("公園")
                        .font(.system(size: 10))
                }

                HStack(spacing: 6) {
                    Image(systemName: "tree.fill")
                        .foregroundStyle(.mint)
                        .font(.system(size: 9))
                    Text("街路樹")
                        .font(.system(size: 10))
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            .transition(.opacity)
        }
    }

    // MARK: - Private

    private var gradientBar: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var gradientColors: [Color] {
        switch viewModel.layerVisibility.heatmapType {
        case .airQuality:
            return [
                Color(red: 0.2, green: 0.7, blue: 0.3),  // Green
                Color(red: 0.8, green: 0.9, blue: 0.0),   // Yellow
                Color(red: 1.0, green: 0.6, blue: 0.0),   // Orange
                Color(red: 1.0, green: 0.0, blue: 0.0)    // Red
            ]
        case .noise:
            return [
                Color(red: 0.0, green: 0.3, blue: 0.8),   // Blue
                Color(red: 0.0, green: 0.8, blue: 0.8),   // Cyan
                Color(red: 0.5, green: 0.8, blue: 0.0),   // Yellow-Green
                Color(red: 1.0, green: 0.2, blue: 0.0)    // Red
            ]
        }
    }

    private var lowLabel: String {
        switch viewModel.layerVisibility.heatmapType {
        case .airQuality: return "良好 (0)"
        case .noise: return "静か (0dB)"
        }
    }

    private var highLabel: String {
        switch viewModel.layerVisibility.heatmapType {
        case .airQuality: return "不良 (300+)"
        case .noise: return "騒音 (100dB)"
        }
    }
}

#Preview {
    LegendView(viewModel: MapViewModel())
        .padding()
        .background(.gray.opacity(0.2))
}
