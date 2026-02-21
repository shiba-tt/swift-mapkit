import SwiftUI

/// Bottom sheet showing details of a selected park or tree
struct DetailSheetView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let park = viewModel.selectedPark {
                        parkDetailContent(park)
                    } else if let tree = viewModel.selectedTree {
                        treeDetailContent(tree)
                    }
                }
                .padding()
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        viewModel.dismissDetail()
                    }
                }
            }
        }
    }

    // MARK: - Navigation Title

    private var navigationTitle: String {
        if let park = viewModel.selectedPark {
            return park.name
        } else if let tree = viewModel.selectedTree {
            return tree.speciesJapanese
        }
        return ""
    }

    // MARK: - Park Detail

    @ViewBuilder
    private func parkDetailContent(_ park: ParkRegion) -> some View {
        // Header with icon
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.title)
                .foregroundStyle(.green)
                .frame(width: 50, height: 50)
                .background(.green.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(park.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("公園")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        // Description
        Text(park.description)
            .font(.body)
            .foregroundStyle(.secondary)

        Divider()

        // Stats grid
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(title: "面積", value: formatArea(park.area), icon: "square.dashed")
            StatCard(title: "樹木数", value: "\(park.treeCount.formatted())本", icon: "tree.fill")
        }

        // Environmental data near the park
        if let dataPoint = viewModel.closestDataPoint(to: park.center) {
            Divider()

            Text("周辺環境データ")
                .font(.subheadline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                EnvironmentStatCard(
                    title: "空気質 (AQI)",
                    value: String(format: "%.0f", dataPoint.airQualityIndex),
                    level: aqiLevel(dataPoint.airQualityIndex),
                    color: aqiColor(dataPoint.airQualityIndex)
                )
                EnvironmentStatCard(
                    title: "騒音レベル",
                    value: String(format: "%.0f dB", dataPoint.noiseLevel),
                    level: noiseLevel(dataPoint.noiseLevel),
                    color: noiseColor(dataPoint.noiseLevel)
                )
            }
        }
    }

    // MARK: - Tree Detail

    @ViewBuilder
    private func treeDetailContent(_ tree: StreetTree) -> some View {
        // Header with icon
        HStack(spacing: 12) {
            Image(systemName: "tree.fill")
                .font(.title)
                .foregroundStyle(.mint)
                .frame(width: 50, height: 50)
                .background(.mint.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(tree.speciesJapanese)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(tree.species)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        Divider()

        // Stats
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "樹高",
                value: String(format: "%.1f m", tree.height),
                icon: "arrow.up.to.line"
            )
            StatCard(
                title: "幹径",
                value: String(format: "%.0f cm", tree.trunkDiameter),
                icon: "circle"
            )
        }

        // Health status
        HStack {
            Text("健康状態")
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Text(tree.healthStatus.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(healthColor(tree.healthStatus))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(healthColor(tree.healthStatus).opacity(0.15))
                .clipShape(Capsule())
        }

        // Environmental data near the tree
        if let dataPoint = viewModel.closestDataPoint(to: tree.coordinate) {
            Divider()

            Text("周辺環境データ")
                .font(.subheadline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                EnvironmentStatCard(
                    title: "空気質 (AQI)",
                    value: String(format: "%.0f", dataPoint.airQualityIndex),
                    level: aqiLevel(dataPoint.airQualityIndex),
                    color: aqiColor(dataPoint.airQualityIndex)
                )
                EnvironmentStatCard(
                    title: "騒音レベル",
                    value: String(format: "%.0f dB", dataPoint.noiseLevel),
                    level: noiseLevel(dataPoint.noiseLevel),
                    color: noiseColor(dataPoint.noiseLevel)
                )
            }
        }
    }

    // MARK: - Helpers

    private func formatArea(_ area: Double) -> String {
        if area >= 10_000 {
            return String(format: "%.1f ha", area / 10_000)
        }
        return "\(Int(area).formatted()) m²"
    }

    private func aqiLevel(_ aqi: Double) -> String {
        switch aqi {
        case 0..<50: return "良好"
        case 50..<100: return "普通"
        case 100..<150: return "敏感な人に不健康"
        case 150..<200: return "不健康"
        default: return "非常に不健康"
        }
    }

    private func aqiColor(_ aqi: Double) -> Color {
        switch aqi {
        case 0..<50: return .green
        case 50..<100: return .yellow
        case 100..<150: return .orange
        default: return .red
        }
    }

    private func noiseLevel(_ db: Double) -> String {
        switch db {
        case 0..<40: return "非常に静か"
        case 40..<55: return "静か"
        case 55..<70: return "普通"
        case 70..<85: return "うるさい"
        default: return "非常にうるさい"
        }
    }

    private func noiseColor(_ db: Double) -> Color {
        switch db {
        case 0..<40: return .blue
        case 40..<55: return .cyan
        case 55..<70: return .yellow
        case 70..<85: return .orange
        default: return .red
        }
    }

    private func healthColor(_ status: TreeHealthStatus) -> Color {
        switch status {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Environment Stat Card

private struct EnvironmentStatCard: View {
    let title: String
    let value: String
    let level: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(level)
                .font(.caption2)
                .foregroundStyle(color)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    DetailSheetView(viewModel: MapViewModel())
}
