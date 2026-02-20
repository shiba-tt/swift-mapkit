import SwiftUI
import MapKit

struct GameMapView: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager
    @State private var selectedZone: GameZone?
    @State private var showZoneDetail = false

    var body: some View {
        ZStack {
            // Map
            GameMapViewRepresentable(
                zones: gameManager.gameState.zones,
                playerLocation: locationManager.coordinate,
                playerTeam: gameManager.currentPlayer.team,
                currentZone: gameManager.currentZone,
                onZoneTapped: { zone in
                    selectedZone = zone
                    showZoneDetail = true
                }
            )
            .ignoresSafeArea(edges: .top)

            // HUD Overlay
            VStack {
                // Top bar
                HStack {
                    // Timer
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.white)
                        Text(gameManager.remainingTimeFormatted)
                            .font(.system(.title3, design: .monospaced, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())

                    Spacer()

                    // Score
                    HStack(spacing: 6) {
                        Image(systemName: gameManager.currentPlayer.team.icon)
                            .foregroundStyle(gameManager.currentPlayer.team.color)
                        Text("\(gameManager.currentPlayer.score)")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                        Text("pt")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Team scores bar
                teamScoresBar
                    .padding(.horizontal)
                    .padding(.top, 4)

                Spacer()

                // Current zone capture indicator
                if let zone = gameManager.currentZone {
                    captureIndicator(for: zone)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }

                // Bottom status
                if gameManager.gameState.phase == .waiting {
                    startGameButton
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                }
            }
        }
        .sheet(isPresented: $showZoneDetail) {
            if let zone = selectedZone {
                ZoneDetailView(zone: zone, playerTeam: gameManager.currentPlayer.team)
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Team Scores Bar

    private var teamScoresBar: some View {
        let scores = gameManager.gameState.teamScores
        let maxScore = max(scores.values.max() ?? 1, 1)

        return HStack(spacing: 4) {
            ForEach(Team.allCases) { team in
                let score = scores[team] ?? 0
                let ratio = CGFloat(score) / CGFloat(maxScore)

                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(team.color)
                        .frame(height: max(4, 20 * ratio))
                    Text("\(score)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(team.color)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Capture Indicator

    private func captureIndicator(for zone: GameZone) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: zone.ownerTeam == gameManager.currentPlayer.team ? "checkmark.shield.fill" : "flag.fill")
                    .foregroundStyle(zone.ownerTeam?.color ?? .gray)
                Text(zone.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(zone.pointsValue)pt")
                    .font(.subheadline.bold())
                    .foregroundStyle(.yellow)
            }

            if zone.ownerTeam != gameManager.currentPlayer.team {
                // Capture progress bar
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.2))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(gameManager.currentPlayer.team.color)
                                .frame(width: geo.size.width * zone.captureProgress)
                                .animation(.easeInOut(duration: 0.3), value: zone.captureProgress)
                        }
                    }
                    .frame(height: 8)

                    Text("占領中... \(Int(zone.captureProgress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            } else {
                Text("自チームが占領済み")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Start Button

    private var startGameButton: some View {
        Button {
            gameManager.startGame()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text("ゲーム開始")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [gameManager.currentPlayer.team.color, gameManager.currentPlayer.team.color.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
    }
}
