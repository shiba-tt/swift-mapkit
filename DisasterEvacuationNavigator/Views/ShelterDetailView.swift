import SwiftUI
import CoreLocation

/// 避難所詳細パネル（マップ下部にオーバーレイ表示）
struct ShelterDetailView: View {
    let shelter: EvacuationShelter
    let location: CLLocation
    let estimatedTravelTime: String?
    let estimatedDistance: String?
    let isLoadingRoute: Bool
    let routeError: String?
    let onClose: () -> Void
    let onNavigate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(shelter.isOpen ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(shelter.isOpen ? "開設中" : "閉鎖中")
                            .font(.caption)
                            .foregroundStyle(shelter.isOpen ? .green : .red)
                    }
                    Text(shelter.name)
                        .font(.headline)
                        .lineLimit(2)
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }

            // 種別タグ
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(shelter.shelterTypes) { type in
                        Label(type.rawValue, systemImage: type.iconName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }

            Divider()

            // 情報セクション
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "mappin.and.ellipse", label: "住所", value: shelter.address)
                InfoRow(icon: "person.3.fill", label: "収容人数", value: "\(shelter.capacity)人")

                if let phone = shelter.phoneNumber {
                    InfoRow(icon: "phone.fill", label: "電話", value: phone)
                }

                InfoRow(
                    icon: "figure.walk",
                    label: "距離",
                    value: shelter.formattedDistance(from: location)
                )

                if let note = shelter.note {
                    InfoRow(icon: "exclamationmark.triangle.fill", label: "備考", value: note)
                }
            }

            // ルート情報
            if isLoadingRoute {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("ルートを計算中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let error = routeError {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let time = estimatedTravelTime, let dist = estimatedDistance {
                HStack(spacing: 16) {
                    Label(time, systemImage: "clock.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    Label(dist, systemImage: "arrow.triangle.swap")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            }

            // ナビゲーションボタン
            Button(action: onNavigate) {
                Label("Apple Mapsで経路案内", systemImage: "map.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
        .padding(.horizontal)
    }
}

/// 情報行コンポーネント
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)
            Text(value)
                .font(.caption)
        }
    }
}
