import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 概要カード
                    overviewSection

                    // 犯罪種別内訳
                    crimeBreakdownSection

                    // カメラ状況
                    cameraSection

                    // 危険エリア
                    dangerZoneSection
                }
                .padding()
            }
            .navigationTitle("統計情報")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        viewModel.showingStats = false
                    }
                }
            }
        }
    }

    // MARK: - 概要セクション
    private var overviewSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    icon: "exclamationmark.triangle.fill",
                    value: "\(viewModel.totalCrimes)",
                    label: "犯罪件数",
                    color: .red
                )
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.totalCrimes - viewModel.unresolvedCrimes)",
                    label: "解決済み",
                    color: .green
                )
            }
            HStack(spacing: 12) {
                StatCard(
                    icon: "video.fill",
                    value: "\(viewModel.totalCameras)",
                    label: "カメラ総数",
                    color: .blue
                )
                StatCard(
                    icon: "shield.fill",
                    value: "\(viewModel.dangerAreaCount)",
                    label: "警戒エリア",
                    color: .orange
                )
            }
        }
    }

    // MARK: - 犯罪種別内訳
    private var crimeBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("犯罪種別内訳")
                .font(.headline)

            ForEach(viewModel.crimesByType, id: \.0) { type, count in
                HStack {
                    Image(systemName: type.icon)
                        .foregroundStyle(type.color)
                        .frame(width: 24)
                    Text(type.rawValue)
                        .font(.subheadline)
                    Spacer()

                    // プログレスバー
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(type.color.opacity(0.3))
                            .frame(width: geo.size.width, height: 20)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(type.color)
                                    .frame(
                                        width: geo.size.width * CGFloat(count) / CGFloat(viewModel.totalCrimes),
                                        height: 20
                                    )
                            }
                    }
                    .frame(width: 100, height: 20)

                    Text("\(count)件")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - カメラ状況
    private var cameraSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("防犯カメラ状況")
                .font(.headline)

            HStack {
                VStack {
                    Text("\(viewModel.activeCameras)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("稼働中")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 50)

                VStack {
                    Text("\(viewModel.totalCameras - viewModel.activeCameras)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                    Text("停止中")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }

            Divider()

            ForEach(CameraType.allCases) { type in
                let count = viewModel.securityCameras.filter { $0.type == type }.count
                if count > 0 {
                    HStack {
                        Image(systemName: type.icon)
                            .foregroundStyle(type.color)
                            .frame(width: 24)
                        Text(type.rawValue)
                            .font(.subheadline)
                        Spacer()
                        Text("\(count)台")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 危険エリア
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("危険エリア一覧")
                .font(.headline)

            ForEach(viewModel.dangerZones.sorted(by: { $0.level > $1.level })) { zone in
                Button {
                    viewModel.selectDangerZone(zone)
                    viewModel.showingStats = false
                    viewModel.moveToLocation(zone.center)
                } label: {
                    HStack {
                        Circle()
                            .fill(zone.level.color)
                            .frame(width: 10, height: 10)

                        Text(zone.name)
                            .font(.subheadline)

                        Spacer()

                        Text(zone.level.label)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(zone.level.color.opacity(0.2))
                            .foregroundStyle(zone.level.color)
                            .clipShape(Capsule())

                        Text("\(zone.crimeCount)件")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 統計カードコンポーネント
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatsView(viewModel: MapViewModel())
}
