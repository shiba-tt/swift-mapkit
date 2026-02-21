import SwiftUI

struct DetailSheetView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let crime = viewModel.selectedCrime {
                        crimeDetailContent(crime)
                    } else if let camera = viewModel.selectedCamera {
                        cameraDetailContent(camera)
                    } else if let zone = viewModel.selectedDangerZone {
                        dangerZoneDetailContent(zone)
                    }
                }
                .padding()
            }
            .navigationTitle(detailTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        viewModel.clearSelection()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var detailTitle: String {
        if viewModel.selectedCrime != nil {
            return "犯罪情報詳細"
        } else if viewModel.selectedCamera != nil {
            return "防犯カメラ詳細"
        } else if viewModel.selectedDangerZone != nil {
            return "危険エリア詳細"
        }
        return ""
    }

    // MARK: - 犯罪詳細
    @ViewBuilder
    private func crimeDetailContent(_ crime: CrimeIncident) -> some View {
        // ヘッダー
        HStack {
            Image(systemName: crime.type.icon)
                .font(.title2)
                .foregroundStyle(crime.type.color)
                .frame(width: 44, height: 44)
                .background(crime.type.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(crime.title)
                    .font(.headline)
                HStack(spacing: 8) {
                    Label(crime.type.rawValue, systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    severityBadge(crime.severity)
                }
            }

            Spacer()

            if crime.isResolved {
                Text("解決済")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
        }

        Divider()

        // 詳細情報
        DetailRow(icon: "calendar", label: "発生日", value: MapViewModel.dateFormatter.string(from: crime.date))
        DetailRow(icon: "mappin.and.ellipse", label: "座標",
                  value: String(format: "%.4f, %.4f", crime.coordinate.latitude, crime.coordinate.longitude))

        Divider()

        // 説明
        Text("概要")
            .font(.subheadline)
            .fontWeight(.semibold)
        Text(crime.description)
            .font(.body)
            .foregroundStyle(.secondary)

        // アクションボタン
        Button {
            viewModel.moveToLocation(crime.coordinate)
        } label: {
            Label("この場所を拡大表示", systemImage: "location.magnifyingglass")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(crime.type.color)
    }

    // MARK: - カメラ詳細
    @ViewBuilder
    private func cameraDetailContent(_ camera: SecurityCamera) -> some View {
        HStack {
            Image(systemName: camera.type.icon)
                .font(.title2)
                .foregroundStyle(camera.type.color)
                .frame(width: 44, height: 44)
                .background(camera.type.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(camera.name)
                    .font(.headline)
                Label(camera.type.rawValue, systemImage: "tag.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(camera.isActive ? .green : .red)
                    .frame(width: 8, height: 8)
                Text(camera.isActive ? "稼働中" : "停止中")
                    .font(.caption)
                    .foregroundStyle(camera.isActive ? .green : .red)
            }
        }

        Divider()

        DetailRow(icon: "calendar", label: "設置日", value: MapViewModel.dateFormatter.string(from: camera.installedDate))
        DetailRow(icon: "circle.dashed", label: "監視範囲", value: "\(Int(camera.coverageRadius))m")
        DetailRow(icon: "mappin.and.ellipse", label: "座標",
                  value: String(format: "%.4f, %.4f", camera.coordinate.latitude, camera.coordinate.longitude))

        Button {
            viewModel.moveToLocation(camera.coordinate)
        } label: {
            Label("この場所を拡大表示", systemImage: "location.magnifyingglass")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(camera.type.color)
    }

    // MARK: - 危険エリア詳細
    @ViewBuilder
    private func dangerZoneDetailContent(_ zone: DangerZone) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(zone.level.color)
                .frame(width: 44, height: 44)
                .background(zone.level.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(zone.name)
                    .font(.headline)
                Text("危険エリア")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            dangerLevelBadge(zone.level)
        }

        Divider()

        DetailRow(icon: "exclamationmark.shield.fill", label: "危険レベル", value: zone.level.label)
        DetailRow(icon: "number", label: "犯罪件数", value: "\(zone.crimeCount)件")
        DetailRow(icon: "circle.dashed", label: "範囲", value: "\(Int(zone.radius))m")
        DetailRow(icon: "clock", label: "最終更新", value: MapViewModel.dateFormatter.string(from: zone.lastUpdated))

        Divider()

        Text("エリア情報")
            .font(.subheadline)
            .fontWeight(.semibold)
        Text(zone.description)
            .font(.body)
            .foregroundStyle(.secondary)

        Button {
            viewModel.moveToLocation(zone.center)
        } label: {
            Label("この場所を拡大表示", systemImage: "location.magnifyingglass")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(zone.level.color)
    }

    // MARK: - ヘルパービュー
    private func severityBadge(_ severity: CrimeIncident.Severity) -> some View {
        Text(severity.label)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(severity.color.opacity(0.2))
            .foregroundStyle(severity.color)
            .clipShape(Capsule())
    }

    private func dangerLevelBadge(_ level: DangerLevel) -> some View {
        Text(level.label)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(level.color.opacity(0.2))
            .foregroundStyle(level.color)
            .clipShape(Capsule())
    }
}

// MARK: - 詳細行コンポーネント
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    let vm = MapViewModel()
    vm.selectedCrime = SampleData.crimeIncidents.first
    vm.showingDetail = true
    return Text("Preview")
        .sheet(isPresented: .constant(true)) {
            DetailSheetView(viewModel: vm)
        }
}
