import SwiftUI

/// 物件詳細シート
struct PropertyDetailView: View {
    let property: Property
    let onLookAround: () -> Void
    let isLoadingLookAround: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.name)
                        .font(.headline)
                    Text(property.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(property.priceText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
            }

            Divider()

            // 物件情報
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                InfoCell(icon: "square.split.2x2", title: "間取り", value: property.layout)
                InfoCell(icon: "ruler", title: "面積", value: "\(String(format: "%.1f", property.area))㎡")
                InfoCell(icon: "calendar", title: "築年", value: property.buildAge)
            }

            // 最寄駅情報
            HStack(spacing: 8) {
                Image(systemName: "tram.fill")
                    .foregroundStyle(.orange)
                Text("\(property.nearestStation)駅")
                    .fontWeight(.medium)
                Text("徒歩\(property.walkMinutes)分")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            // Look Around ボタン
            Button(action: onLookAround) {
                HStack {
                    if isLoadingLookAround {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "binoculars.fill")
                    }
                    Text("周辺を見る (Look Around)")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isLoadingLookAround)
        }
        .padding()
    }
}

/// 情報セル
private struct InfoCell: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
