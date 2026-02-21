import SwiftUI

/// 配達管理ダッシュボードのメインビュー。
/// 地図、統計情報、ドライバーリスト、配達一覧を統合表示する。
struct DashboardView: View {
    @EnvironmentObject var manager: DeliveryManager

    var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationTitle("配達管理")
                #if os(macOS)
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
                #endif
        } detail: {
            ZStack(alignment: .top) {
                DeliveryMapView()

                // 統計カードのオーバーレイ
                StatsOverlayView(stats: manager.stats)
                    .padding()

                // 選択中ドライバーの詳細パネル
                if let driverID = manager.selectedDriverID,
                   let driver = manager.drivers.first(where: { $0.id == driverID }) {
                    VStack {
                        Spacer()
                        SelectedDriverPanel(
                            driver: driver,
                            delivery: manager.deliveries.first { $0.id == driver.currentDeliveryID },
                            route: manager.routes.first { $0.driverID == driverID },
                            onOptimize: { manager.optimizeRoute(for: driverID) },
                            onDismiss: { manager.selectDriver(nil) }
                        )
                        .padding()
                    }
                }
            }
        }
    }

    // MARK: - Sidebar

    @ViewBuilder
    private var sidebarContent: some View {
        List(selection: Binding(
            get: { manager.selectedDriverID },
            set: { manager.selectDriver($0) }
        )) {
            // ドライバーセクション
            Section {
                ForEach(manager.drivers) { driver in
                    DriverRowView(driver: driver)
                        .tag(driver.id)
                }
            } header: {
                Label("ドライバー (\(manager.drivers.count))", systemImage: "person.3.fill")
            }

            // 配達セクション
            Section {
                ForEach(manager.deliveries) { delivery in
                    DeliveryRowView(delivery: delivery)
                }
            } header: {
                Label("配達一覧 (\(manager.deliveries.count))", systemImage: "shippingbox.fill")
            }
        }
        .listStyle(.sidebar)
    }
}

// MARK: - Stats Overlay

struct StatsOverlayView: View {
    let stats: DashboardStats

    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "総配達数",
                value: "\(stats.totalDeliveries)",
                icon: "shippingbox.fill",
                color: .blue
            )
            StatCard(
                title: "完了",
                value: "\(stats.completedDeliveries)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            StatCard(
                title: "稼働中",
                value: "\(stats.activeDrivers)",
                icon: "car.fill",
                color: .orange
            )
            StatCard(
                title: "定時率",
                value: "\(Int(stats.onTimeRate * 100))%",
                icon: "clock.fill",
                color: .purple
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
    }
}

// MARK: - Driver Row

struct DriverRowView: View {
    let driver: Driver

    var body: some View {
        HStack(spacing: 10) {
            // ステータスアイコン
            Image(systemName: driver.status.systemImage)
                .font(.title3)
                .foregroundStyle(driverStatusColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(driver.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Image(systemName: driver.vehicleType.systemImage)
                        .font(.caption2)
                    Text(driver.status.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // 完了数バッジ
            Text("\(driver.completedCount)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(driverStatusColor, in: Capsule())
        }
        .padding(.vertical, 2)
    }

    private var driverStatusColor: Color {
        switch driver.status {
        case .idle: return .gray
        case .enRoute: return .blue
        case .delivering: return .orange
        case .returning: return .green
        }
    }
}

// MARK: - Delivery Row

struct DeliveryRowView: View {
    let delivery: Delivery

    var body: some View {
        HStack(spacing: 10) {
            // ステータスインジケーター
            Circle()
                .fill(deliveryStatusColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(delivery.orderNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.indigo)
                    Text(delivery.pickupAddress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    Text(delivery.dropoffAddress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(delivery.status.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(deliveryStatusColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(deliveryStatusColor.opacity(0.1), in: Capsule())
        }
        .padding(.vertical, 2)
    }

    private var deliveryStatusColor: Color {
        switch delivery.status {
        case .pending: return .gray
        case .assigned: return .blue
        case .pickedUp: return .indigo
        case .inTransit: return .orange
        case .delivered: return .green
        case .failed: return .red
        }
    }
}

// MARK: - Selected Driver Panel

struct SelectedDriverPanel: View {
    let driver: Driver
    let delivery: Delivery?
    let route: DeliveryRoute?
    let onOptimize: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: driver.vehicleType.systemImage)
                    .font(.title2)
                    .foregroundStyle(.blue)
                VStack(alignment: .leading) {
                    Text(driver.name)
                        .font(.headline)
                    Text(driver.status.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // 配達情報
            if let delivery {
                VStack(alignment: .leading, spacing: 6) {
                    Text("配達情報")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    InfoRow(icon: "number", label: "注文番号", value: delivery.orderNumber)
                    InfoRow(icon: "arrow.up.circle", label: "集荷", value: delivery.pickupAddress)
                    InfoRow(icon: "mappin", label: "配達先", value: delivery.dropoffAddress)

                    if let eta = delivery.estimatedArrival {
                        InfoRow(
                            icon: "clock",
                            label: "到着予定",
                            value: eta.formatted(date: .omitted, time: .shortened)
                        )
                    }
                }
            }

            // ルート情報 & 最適化ボタン
            if let route {
                Divider()
                RouteInfoView(route: route, onOptimize: onOptimize)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        .frame(maxWidth: 400)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}
