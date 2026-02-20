import SwiftUI

/// 交通情報パネル（ボトムシート内に表示）
struct TrafficInfoPanel: View {
    @ObservedObject var viewModel: TrafficViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            headerSection

            Divider()

            // 渋滞サマリー
            summarySection

            Divider()

            // ルート一覧
            routeListSection

            Divider()

            // 渋滞ポイント一覧
            congestionPointsSection
        }
        .padding()
    }

    // MARK: - ヘッダー

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("交通状況")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("最終更新: \(viewModel.lastUpdatedText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 更新ボタン
            Button(action: { viewModel.refreshData() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
            }

            // 自動更新トグル
            Button(action: { viewModel.toggleAutoRefresh() }) {
                Image(systemName: viewModel.isAutoRefreshing ? "timer.circle.fill" : "timer")
                    .font(.title3)
                    .foregroundColor(viewModel.isAutoRefreshing ? .blue : .gray)
            }
        }
    }

    // MARK: - サマリー

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.trafficSummary)
                .font(.subheadline)
                .foregroundColor(.primary)

            if let recommended = viewModel.recommendedRoute {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("推奨: \(recommended.name)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("(\(recommended.travelTimeText))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - ルート一覧

    private var routeListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ルート比較")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(viewModel.visibleRoutes) { route in
                RouteRow(
                    route: route,
                    isSelected: viewModel.selectedRoute?.id == route.id,
                    isRecommended: viewModel.recommendedRoute?.id == route.id
                )
                .onTapGesture {
                    viewModel.selectRoute(route)
                }
            }
        }
    }

    // MARK: - 渋滞ポイント一覧

    private var congestionPointsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("渋滞ポイント")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(viewModel.visibleCongestionPoints) { point in
                CongestionPointRow(point: point)
            }
        }
    }
}

// MARK: - ルート行

struct RouteRow: View {
    let route: TrafficRoute
    let isSelected: Bool
    let isRecommended: Bool

    var body: some View {
        HStack(spacing: 10) {
            // 渋滞レベルインジケーター
            Circle()
                .fill(route.worstTrafficLevel.swiftUIColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(route.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    if route.isDetour {
                        Text("迂回")
                            .font(.system(size: 9))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(3)
                    }

                    if isRecommended {
                        Text("推奨")
                            .font(.system(size: 9))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(3)
                    }
                }

                HStack(spacing: 8) {
                    Label(route.distanceText, systemImage: "arrow.left.and.right")
                    Label(route.travelTimeText, systemImage: "clock")
                    if route.congestedSegmentCount > 0 {
                        Label("\(route.congestedSegmentCount)区間渋滞", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                    }
                }
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(isSelected ? Color.blue.opacity(0.08) : Color.clear)
        .cornerRadius(8)
    }
}

// MARK: - 渋滞ポイント行

struct CongestionPointRow: View {
    let point: CongestionPoint

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: point.trafficLevel.icon)
                .foregroundColor(point.trafficLevel.swiftUIColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(point.roadName)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(point.description)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(point.trafficLevel.displayName)
                .font(.system(size: 10))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(point.trafficLevel.swiftUIColor.opacity(0.2))
                .foregroundColor(point.trafficLevel.swiftUIColor)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}
