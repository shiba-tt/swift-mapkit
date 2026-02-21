import SwiftUI

struct GameDashboardView: View {
    @ObservedObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Player Info Card
                playerCard

                // Team Standings
                teamStandingsCard

                // Zone Status
                zoneStatusCard

                // Event Log
                eventLogCard
            }
            .padding()
        }
        .background(Color.gameBackground)
        .navigationTitle("ダッシュボード")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Player Card

    private var playerCard: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(gameManager.currentPlayer.team.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: gameManager.currentPlayer.team.icon)
                        .font(.title2)
                        .foregroundStyle(gameManager.currentPlayer.team.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(gameManager.currentPlayer.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(gameManager.currentPlayer.team.displayName)
                        .font(.subheadline)
                        .foregroundStyle(gameManager.currentPlayer.team.color)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(gameManager.currentPlayer.score)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.yellow)
                    Text("ポイント")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }

            Divider().background(.gray.opacity(0.3))

            HStack {
                statItem(value: "\(gameManager.currentPlayer.capturedZoneCount)", label: "占領数")
                Divider().frame(height: 30).background(.gray.opacity(0.3))
                statItem(
                    value: "\(gameManager.gameState.zones.filter { $0.ownerTeam == gameManager.currentPlayer.team }.count)",
                    label: "保持ゾーン"
                )
                Divider().frame(height: 30).background(.gray.opacity(0.3))
                statItem(value: gameManager.remainingTimeFormatted, label: "残り時間")
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Team Standings

    private var teamStandingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("チーム順位")
                .font(.headline)
                .foregroundStyle(.white)

            let scores = gameManager.gameState.teamScores
            let sorted = scores.sorted { $0.value > $1.value }

            ForEach(Array(sorted.enumerated()), id: \.element.key) { index, entry in
                let team = entry.key
                let score = entry.value
                let maxScore = max(sorted.first?.value ?? 1, 1)

                HStack(spacing: 10) {
                    Text("#\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 24)

                    Image(systemName: team.icon)
                        .foregroundStyle(team.color)
                        .frame(width: 20)

                    Text(team.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.white)

                    Spacer()

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(team.color.opacity(0.6))
                                .frame(width: geo.size.width * CGFloat(score) / CGFloat(maxScore))
                        }
                    }
                    .frame(width: 80, height: 8)

                    Text("\(score)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(team.color)
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Zone Status

    private var zoneStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ゾーン状況")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(gameManager.gameState.zones) { zone in
                HStack(spacing: 10) {
                    Circle()
                        .fill(zone.ownerTeam?.color ?? .gray)
                        .frame(width: 10, height: 10)

                    Text(zone.name)
                        .font(.subheadline)
                        .foregroundStyle(.white)

                    Spacer()

                    if let team = zone.ownerTeam {
                        Text(team.displayName)
                            .font(.caption)
                            .foregroundStyle(team.color)
                    } else {
                        Text("中立")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    Text("\(zone.pointsValue)pt")
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                        .frame(width: 40, alignment: .trailing)
                }

                if zone.isBeingCaptured {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 2)
                                .fill((zone.capturingTeam?.color ?? .white).opacity(0.6))
                                .frame(width: geo.size.width * zone.captureProgress)
                        }
                    }
                    .frame(height: 4)
                }
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Event Log

    private var eventLogCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("イベントログ")
                .font(.headline)
                .foregroundStyle(.white)

            if gameManager.events.isEmpty {
                Text("イベントはまだありません")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(gameManager.events.prefix(15)) { event in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(event.team?.color ?? .gray)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.message)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                            Text(formatEventTime(event.timestamp))
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    private func formatEventTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}
