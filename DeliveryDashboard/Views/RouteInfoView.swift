import SwiftUI
import MapKit

/// ルート最適化情報を表示するビュー。
/// 距離、所要時間、ウェイポイント一覧、最適化ボタンを含む。
struct RouteInfoView: View {
    let route: DeliveryRoute
    let onOptimize: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ルート情報")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                if route.isOptimized {
                    Label("最適化済", systemImage: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.green.opacity(0.1), in: Capsule())
                }
            }

            // 距離・時間
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "road.lanes")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text(formattedDistance)
                        .font(.caption)
                        .fontWeight(.medium)
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text(formattedDuration)
                        .font(.caption)
                        .fontWeight(.medium)
                }

                HStack(spacing: 4) {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.caption)
                        .foregroundStyle(.purple)
                    Text("\(route.waypoints.count) 地点")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }

            // ウェイポイントリスト
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(route.waypoints.enumerated()), id: \.element.id) { index, waypoint in
                    HStack(spacing: 8) {
                        // 順序表示用の縦線
                        VStack(spacing: 0) {
                            if index > 0 {
                                Rectangle()
                                    .fill(lineColor(for: waypoint.type))
                                    .frame(width: 2, height: 8)
                            }
                            Circle()
                                .fill(waypointColor(for: waypoint.type))
                                .frame(width: 8, height: 8)
                            if index < route.waypoints.count - 1 {
                                Rectangle()
                                    .fill(lineColor(for: waypoint.type))
                                    .frame(width: 2, height: 8)
                            }
                        }
                        .frame(width: 12)

                        Image(systemName: waypointIcon(for: waypoint.type))
                            .font(.caption2)
                            .foregroundStyle(waypointColor(for: waypoint.type))
                            .frame(width: 14)

                        Text(waypoint.label)
                            .font(.caption)

                        Spacer()

                        Text("\(waypoint.order + 1)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 16, height: 16)
                            .background(.quaternary, in: Circle())
                    }
                }
            }

            // 最適化ボタン
            if !route.isOptimized {
                Button(action: onOptimize) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("ルートを最適化")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            } else {
                // 最適化結果の表示
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundStyle(.green)
                    VStack(alignment: .leading) {
                        Text("ルート最適化完了")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("推定 15% の時間短縮")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    // MARK: - Formatting

    private var formattedDistance: String {
        if route.totalDistance >= 1000 {
            return String(format: "%.1f km", route.totalDistance / 1000)
        }
        return String(format: "%.0f m", route.totalDistance)
    }

    private var formattedDuration: String {
        let minutes = Int(route.estimatedDuration / 60)
        if minutes >= 60 {
            return "\(minutes / 60)時間\(minutes % 60)分"
        }
        return "\(minutes)分"
    }

    // MARK: - Waypoint Styling

    private func waypointColor(for type: DeliveryRoute.Waypoint.WaypointType) -> Color {
        switch type {
        case .pickup: return .indigo
        case .dropoff: return .red
        case .warehouse: return .brown
        }
    }

    private func waypointIcon(for type: DeliveryRoute.Waypoint.WaypointType) -> String {
        switch type {
        case .pickup: return "arrow.up.circle.fill"
        case .dropoff: return "mappin.circle.fill"
        case .warehouse: return "building.2.fill"
        }
    }

    private func lineColor(for type: DeliveryRoute.Waypoint.WaypointType) -> Color {
        waypointColor(for: type).opacity(0.4)
    }
}
