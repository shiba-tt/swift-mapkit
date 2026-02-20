import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Winner banner (if game finished)
                if gameManager.gameState.phase == .finished {
                    winnerBanner
                }

                // Team rankings
                teamRankings

                // Zone ownership summary
                zoneOwnershipChart

                // Game stats
                gameStats
            }
            .padding()
        }
        .background(Color.gameBackground)
        .navigationTitle("リーダーボード")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Winner Banner

    private var winnerBanner: some View {
        VStack(spacing: 12) {
            if let winner = gameManager.gameState.leadingTeam {
                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.yellow)

                Text("\(winner.displayName)の勝利！")
                    .font(.title.bold())
                    .foregroundStyle(winner.color)

                Text("スコア: \(gameManager.gameState.teamScores[winner] ?? 0)pt")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [
                    (gameManager.gameState.leadingTeam?.color ?? .gray).opacity(0.3),
                    Color.cardBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // MARK: - Team Rankings

    private var teamRankings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("チームランキング")
                .font(.headline)
                .foregroundStyle(.white)

            let scores = gameManager.gameState.teamScores
            let sorted = scores.sorted { $0.value > $1.value }

            ForEach(Array(sorted.enumerated()), id: \.element.key) { index, entry in
                let team = entry.key
                let score = entry.value
                let zonesOwned = gameManager.gameState.zones.filter { $0.ownerTeam == team }.count

                HStack(spacing: 12) {
                    // Rank badge
                    ZStack {
                        Circle()
                            .fill(rankColor(index))
                            .frame(width: 32, height: 32)
                        Text("\(index + 1)")
                            .font(.system(.subheadline, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    // Team info
                    Image(systemName: team.icon)
                        .font(.title3)
                        .foregroundStyle(team.color)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(team.displayName)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                        Text("\(zonesOwned)ゾーン占領中")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    Spacer()

                    Text("\(score)pt")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(team.color)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow.opacity(0.8)
        case 1: return .gray.opacity(0.6)
        case 2: return .orange.opacity(0.6)
        default: return .gray.opacity(0.3)
        }
    }

    // MARK: - Zone Ownership Chart

    private var zoneOwnershipChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ゾーン支配率")
                .font(.headline)
                .foregroundStyle(.white)

            let totalZones = gameManager.gameState.zones.count
            guard totalZones > 0 else {
                return AnyView(Text("ゾーンなし").foregroundStyle(.gray))
            }

            let zoneCounts: [(Team?, Int)] = {
                var counts: [(Team?, Int)] = []
                for team in Team.allCases {
                    let count = gameManager.gameState.zones.filter { $0.ownerTeam == team }.count
                    if count > 0 { counts.append((team, count)) }
                }
                let neutralCount = gameManager.gameState.zones.filter { $0.ownerTeam == nil }.count
                if neutralCount > 0 { counts.append((nil, neutralCount)) }
                return counts
            }()

            return AnyView(
                VStack(spacing: 8) {
                    // Stacked bar
                    GeometryReader { geo in
                        HStack(spacing: 2) {
                            ForEach(Array(zoneCounts.enumerated()), id: \.offset) { _, entry in
                                let ratio = CGFloat(entry.1) / CGFloat(totalZones)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(entry.0?.color ?? .gray)
                                    .frame(width: max(geo.size.width * ratio - 2, 4))
                            }
                        }
                    }
                    .frame(height: 24)

                    // Legend
                    HStack(spacing: 16) {
                        ForEach(Array(zoneCounts.enumerated()), id: \.offset) { _, entry in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(entry.0?.color ?? .gray)
                                    .frame(width: 8, height: 8)
                                Text(entry.0?.displayName ?? "中立")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.7))
                                Text("\(entry.1)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            )
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Game Stats

    private var gameStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ゲーム統計")
                .font(.headline)
                .foregroundStyle(.white)

            let stats: [(String, String)] = [
                ("総ゾーン数", "\(gameManager.gameState.zones.count)"),
                ("占領済みゾーン", "\(gameManager.gameState.zones.filter { $0.ownerTeam != nil }.count)"),
                ("中立ゾーン", "\(gameManager.gameState.zones.filter { $0.ownerTeam == nil }.count)"),
                ("ゲーム状態", gameManager.gameState.phase.rawValue),
                ("残り時間", gameManager.remainingTimeFormatted),
            ]

            ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                HStack {
                    Text(stat.0)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text(stat.1)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }
}
