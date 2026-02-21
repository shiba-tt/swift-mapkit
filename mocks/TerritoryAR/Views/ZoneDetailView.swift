import SwiftUI

struct ZoneDetailView: View {
    let zone: GameZone
    let playerTeam: Team

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection

                    // Status
                    statusSection

                    // Points info
                    pointsSection

                    // Capture info
                    if zone.ownerTeam != playerTeam {
                        captureInfoSection
                    }
                }
                .padding()
            }
        }
        .background(Color.gameBackground)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill((zone.ownerTeam?.color ?? .gray).opacity(0.2))
                    .frame(width: 56, height: 56)
                Image(systemName: zone.ownerTeam?.icon ?? "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(zone.ownerTeam?.color ?? .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(zone.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                if let team = zone.ownerTeam {
                    Text("\(team.displayName)が占領中")
                        .font(.subheadline)
                        .foregroundStyle(team.color)
                } else {
                    Text("中立ゾーン")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
            }

            Spacer()
        }
    }

    // MARK: - Status

    private var statusSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("ステータス")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            HStack(spacing: 16) {
                statusItem(
                    icon: "shield.fill",
                    title: "防御力",
                    value: "\(Int(zone.captureProgress * 100))%",
                    color: zone.ownerTeam?.color ?? .gray
                )

                statusItem(
                    icon: "star.fill",
                    title: "ポイント",
                    value: "\(zone.pointsValue)",
                    color: .yellow
                )

                if let date = zone.lastCapturedDate {
                    statusItem(
                        icon: "clock.fill",
                        title: "占領時刻",
                        value: timeAgo(date),
                        color: .blue
                    )
                }
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }

    private func statusItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Points

    private var pointsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("獲得ポイント")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            VStack(spacing: 4) {
                pointsRow("占領ボーナス", points: zone.pointsValue)
                pointsRow("維持ボーナス (10秒毎)", points: 10)
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }

    private func pointsRow(_ label: String, points: Int) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
            Text("+\(points)pt")
                .font(.subheadline.bold())
                .foregroundStyle(.yellow)
        }
    }

    // MARK: - Capture Info

    private var captureInfoSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("占領方法")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                infoRow(number: 1, text: "ゾーン内に移動してください")
                infoRow(number: 2, text: "ゾーン内に留まると自動的に占領が進みます")
                infoRow(number: 3, text: "敵チームのゾーンはまず中立に戻す必要があります")
                infoRow(number: 4, text: "ゾーンから離れると占領がリセットされます")
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(.blue))

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    // MARK: - Helpers

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "\(seconds)秒前" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)分前" }
        return "\(minutes / 60)時間前"
    }
}
