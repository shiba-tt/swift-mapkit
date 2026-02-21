import SwiftUI

/// 散策ルート一覧ビュー
struct RouteListView: View {
    @ObservedObject var viewModel: HistoricalSiteViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.routes) { route in
                    RouteCard(route: route, sites: sitesForRoute(route))
                        .onTapGesture {
                            viewModel.selectRoute(route)
                            dismiss()
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
            .listStyle(.plain)
            .navigationTitle("散策ルート")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sitesForRoute(_ route: WalkingRoute) -> [HistoricalSite] {
        route.siteIDs.compactMap { id in
            viewModel.allSites.first { $0.id == id }
        }
    }
}

// MARK: - Route Card

struct RouteCard: View {
    let route: WalkingRoute
    let sites: [HistoricalSite]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: route.difficulty.iconName)
                    .font(.title2)
                    .foregroundStyle(difficultyColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(route.name)
                        .font(.headline)

                    Text(route.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // ルート情報
            HStack(spacing: 16) {
                RouteStatChip(icon: "clock", value: "\(route.estimatedDurationMinutes)分")
                RouteStatChip(icon: "figure.walk", value: String(format: "%.1fkm", route.distanceKilometers))
                RouteStatChip(icon: "gauge.medium", value: route.difficulty.rawValue)
            }

            // ルート上の史跡
            VStack(alignment: .leading, spacing: 8) {
                Text("立ち寄りスポット")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(Array(sites.enumerated()), id: \.element.id) { index, site in
                    HStack(spacing: 8) {
                        // 番号バッジ
                        ZStack {
                            Circle()
                                .fill(.blue)
                                .frame(width: 24, height: 24)
                            Text("\(index + 1)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }

                        // 接続線
                        if index < sites.count - 1 {
                            VStack(spacing: 0) {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: 2, height: 0)
                            }
                        }

                        Image(systemName: site.category.iconName)
                            .font(.caption)
                            .foregroundStyle(siteEraColor(site))
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(site.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(site.era.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    if index < sites.count - 1 {
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(.secondary.opacity(0.3))
                                .frame(width: 2, height: 12)
                                .padding(.leading, 11)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        .contentShape(Rectangle())
    }

    private var difficultyColor: Color {
        switch route.difficulty {
        case .easy: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }

    private func siteEraColor(_ site: HistoricalSite) -> Color {
        switch site.era {
        case .jomon, .yayoi, .kofun: return .brown
        case .asuka, .nara: return .orange
        case .heian: return .purple
        case .kamakura, .muromachi: return .blue
        case .azuchiMomoyama: return .red
        case .edo: return .indigo
        case .meiji, .taisho, .showa: return .green
        }
    }
}

// MARK: - Route Stat Chip

struct RouteStatChip: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.secondary.opacity(0.1), in: Capsule())
    }
}
