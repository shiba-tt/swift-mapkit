import SwiftUI
import MapKit

/// 史跡の詳細情報ビュー
struct SiteDetailView: View {
    let site: HistoricalSite
    @ObservedObject var viewModel: HistoricalSiteViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // ヘッダーマップ
                    headerMap

                    VStack(alignment: .leading, spacing: 20) {
                        // タイトルセクション
                        titleSection

                        Divider()

                        // 概要
                        summarySection

                        Divider()

                        // 詳細説明
                        descriptionSection

                        // 関連人物
                        if !site.historicalFigures.isEmpty {
                            Divider()
                            historicalFiguresSection
                        }

                        // 歴史的イベント
                        if !site.historicalEvents.isEmpty {
                            Divider()
                            historicalEventsSection
                        }

                        Divider()

                        // 訪問情報
                        visitInfoSection

                        // ARボタン
                        Divider()
                        arSection

                        // マップで表示
                        Divider()
                        mapActionSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle(site.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        // お気に入りボタン
                        Button {
                            viewModel.toggleFavorite(for: site)
                        } label: {
                            Image(systemName: viewModel.isFavorite(site) ? "heart.fill" : "heart")
                                .foregroundStyle(viewModel.isFavorite(site) ? .red : .secondary)
                        }

                        // 閉じるボタン
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Header Map

    private var headerMap: some View {
        Map {
            Marker(site.name, coordinate: site.coordinate)
                .tint(markerColor)
        }
        .mapStyle(.imagery(elevation: .realistic))
        .frame(height: 200)
        .allowsHitTesting(false)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(site.name)
                        .font(.title)
                        .fontWeight(.bold)

                    if !site.nameReading.isEmpty {
                        Text(site.nameReading)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // カテゴリアイコン
                VStack(spacing: 4) {
                    Image(systemName: site.category.iconName)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(markerColor, in: RoundedRectangle(cornerRadius: 12))

                    Text(site.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // 時代・年代タグ
            HStack(spacing: 8) {
                EraTag(era: site.era)

                Text(site.yearBuilt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.1), in: Capsule())
            }
        }
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "概要", icon: "text.quote")

            Text(site.summary)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "歴史", icon: "book.fill")

            Text(site.description)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Historical Figures Section

    private var historicalFiguresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "関連人物", icon: "person.2.fill")

            FlowLayout(spacing: 8) {
                ForEach(site.historicalFigures, id: \.self) { figure in
                    Text(figure)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.1), in: Capsule())
                }
            }
        }
    }

    // MARK: - Historical Events Section

    private var historicalEventsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "主要な出来事", icon: "calendar.badge.clock")

            VStack(alignment: .leading, spacing: 6) {
                ForEach(site.historicalEvents, id: \.self) { event in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(markerColor)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)

                        Text(event)
                            .font(.subheadline)
                    }
                }
            }
        }
    }

    // MARK: - Visit Info Section

    private var visitInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "訪問情報", icon: "info.circle.fill")

            VStack(spacing: 8) {
                InfoRow(icon: "mappin.circle.fill", label: "住所", value: site.address)

                if !site.visitingHours.isEmpty {
                    InfoRow(icon: "clock.fill", label: "拝観時間", value: site.visitingHours)
                }

                if !site.admissionFee.isEmpty {
                    InfoRow(icon: "yensign.circle.fill", label: "拝観料", value: site.admissionFee)
                }
            }
        }
    }

    // MARK: - AR Section

    private var arSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "ARで歴史を体験", icon: "arkit")

            Text(site.arDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(2)

            Button {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.showAR(for: site)
                }
            } label: {
                HStack {
                    Image(systemName: "arkit")
                    Text("ARで当時の風景を見る")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(markerColor, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Map Action Section

    private var mapActionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "アクセス", icon: "map.fill")

            // ミニマップ
            Map {
                Marker(site.name, coordinate: site.coordinate)
                    .tint(markerColor)
            }
            .mapStyle(.standard)
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)

            // Mapsで開くボタン
            Button {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: site.coordinate))
                mapItem.name = site.name
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                ])
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    Text("マップアプリで経路を表示")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Helpers

    private var markerColor: Color {
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

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding(10)
        .background(.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct EraTag: View {
    let era: HistoricalEra

    var body: some View {
        Text(era.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(eraColor, in: Capsule())
    }

    private var eraColor: Color {
        switch era {
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

// MARK: - Flow Layout

/// 自動折り返しレイアウト
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}
