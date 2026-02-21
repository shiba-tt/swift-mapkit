import SwiftUI

/// Panel for toggling map layers and selecting heatmap data type
struct FilterPanelView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("表示レイヤー")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            // Park layer toggle
            LayerToggle(
                icon: "leaf.fill",
                label: "公園",
                color: .green,
                isOn: $viewModel.layerVisibility.showParks
            )

            // Street tree layer toggle
            LayerToggle(
                icon: "tree.fill",
                label: "街路樹",
                color: .mint,
                isOn: $viewModel.layerVisibility.showStreetTrees
            )

            Divider()

            // Heatmap toggle
            LayerToggle(
                icon: "square.grid.3x3.fill",
                label: "ヒートマップ",
                color: .orange,
                isOn: $viewModel.layerVisibility.showHeatmap
            )

            // Heatmap type selector
            if viewModel.layerVisibility.showHeatmap {
                VStack(alignment: .leading, spacing: 8) {
                    Text("データ種別")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Picker("", selection: $viewModel.layerVisibility.heatmapType) {
                        ForEach(HeatmapDataType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .transition(.opacity)
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
    }
}

// MARK: - Layer Toggle Row

private struct LayerToggle: View {
    let icon: String
    let label: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(isOn ? color : .gray)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .scaleEffect(0.8)
        }
    }
}

#Preview {
    FilterPanelView(viewModel: MapViewModel())
        .padding()
}
