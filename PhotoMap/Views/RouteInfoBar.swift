import SwiftUI

/// ルート情報を表示するバー
struct RouteInfoBar: View {
    let statistics: RouteStatistics
    let showRoute: Bool

    var body: some View {
        HStack(spacing: 16) {
            infoItem(
                icon: "photo.stack",
                value: "\(statistics.totalPhotos)",
                label: "枚"
            )

            if showRoute {
                Divider()
                    .frame(height: 24)

                infoItem(
                    icon: "point.topleft.down.to.point.bottomright.curvepath",
                    value: statistics.formattedDistance,
                    label: "総距離"
                )

                if let duration = statistics.formattedDuration {
                    Divider()
                        .frame(height: 24)

                    infoItem(
                        icon: "clock",
                        value: duration,
                        label: "撮影時間"
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }

    private func infoItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.blue)

            Text(value)
                .font(.caption.bold())

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
