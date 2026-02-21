import SwiftUI

/// 浸水深凡例ビュー
struct FloodZoneLegendView: View {
    @Binding var showFloodZones: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "water.waves")
                    .foregroundStyle(.blue)
                Text("浸水想定区域")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Toggle("", isOn: $showFloodZones)
                    .labelsHidden()
                    .scaleEffect(0.75)
            }

            if showFloodZones {
                ForEach(FloodDepthLevel.allCases) { level in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(level.color)
                            .overlay(
                                Circle().stroke(level.strokeColor, lineWidth: 1)
                            )
                            .frame(width: 16, height: 16)
                        Text(level.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}
