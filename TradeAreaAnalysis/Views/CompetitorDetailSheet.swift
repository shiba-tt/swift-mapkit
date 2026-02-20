import MapKit
import SwiftUI

/// 競合店舗の詳細シート
struct CompetitorDetailSheet: View {
    let competitor: Competitor
    let center: CLLocationCoordinate2D

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー
                    headerSection

                    Divider()

                    // 詳細情報
                    detailSection

                    Divider()

                    // ミニマップ
                    miniMapSection
                }
                .padding()
            }
            .navigationTitle("店舗詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - ヘッダー

    private var headerSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(competitor.category.color.gradient)
                    .frame(width: 56, height: 56)

                Image(systemName: competitor.category.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(competitor.name)
                    .font(.title3.bold())
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text(competitor.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(competitor.category.color.opacity(0.15), in: Capsule())
                        .foregroundStyle(competitor.category.color)

                    Text(competitor.formattedDistance)
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                }
            }

            Spacer()
        }
    }

    // MARK: - 詳細情報

    private var detailSection: some View {
        VStack(spacing: 12) {
            DetailRow(
                icon: "mappin.and.ellipse",
                label: "住所",
                value: competitor.address
            )

            DetailRow(
                icon: "ruler",
                label: "中心からの距離",
                value: competitor.formattedDistance
            )

            DetailRow(
                icon: "location",
                label: "座標",
                value: String(
                    format: "%.6f, %.6f",
                    competitor.coordinate.latitude,
                    competitor.coordinate.longitude
                )
            )

            if let phone = competitor.phoneNumber {
                DetailRow(icon: "phone", label: "電話番号", value: phone)
            }

            if let url = competitor.url {
                HStack {
                    Image(systemName: "globe")
                        .frame(width: 24)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading) {
                        Text("ウェブサイト")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Link(url.host ?? url.absoluteString, destination: url)
                            .font(.subheadline)
                    }
                    Spacer()
                }
            }
        }
    }

    // MARK: - ミニマップ

    private var miniMapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("位置")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)

            Map {
                // 中心点
                Annotation("分析中心", coordinate: center) {
                    Image(systemName: "target")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // 競合マーカー
                Marker(competitor.name, coordinate: competitor.coordinate)
                    .tint(competitor.category.color)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)
        }
    }
}

/// 詳細行コンポーネント
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }

            Spacer()
        }
    }
}
