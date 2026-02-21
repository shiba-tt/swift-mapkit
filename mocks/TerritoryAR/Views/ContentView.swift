import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var gameManager = GameManager()
    @State private var selectedTab = 0
    @State private var showSetup = true
    @State private var playerName = ""
    @State private var selectedTeam: Team = .blue

    var body: some View {
        Group {
            if showSetup {
                setupView
            } else {
                mainGameView
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: locationManager.currentLocation) { _, newLocation in
            if let coordinate = newLocation?.coordinate {
                gameManager.updatePlayerLocation(coordinate)
            }
        }
    }

    // MARK: - Setup View

    private var setupView: some View {
        ZStack {
            Color.gameBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Territory AR")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("位置情報ARで陣取りバトル")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }

                // Player Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("プレイヤー名")
                        .font(.headline)
                        .foregroundStyle(.white)

                    TextField("名前を入力", text: $playerName)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)

                // Team Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("チームを選択")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(Team.allCases) { team in
                            teamSelectionCard(team)
                        }
                    }
                    .padding(.horizontal)
                }

                // Location Status
                locationStatusView
                    .padding(.horizontal)

                Spacer()

                // Start Button
                Button {
                    startGame()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("ゲームに参加")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: canStart
                                ? [selectedTeam.color, selectedTeam.color.opacity(0.7)]
                                : [.gray, .gray.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                .disabled(!canStart)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    }

    private func teamSelectionCard(_ team: Team) -> some View {
        Button {
            selectedTeam = team
        } label: {
            VStack(spacing: 8) {
                Image(systemName: team.icon)
                    .font(.title)
                    .foregroundStyle(team.color)
                Text(team.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedTeam == team ? team.color.opacity(0.2) : Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedTeam == team ? team.color : .clear, lineWidth: 2)
                    )
            )
        }
    }

    private var locationStatusView: some View {
        HStack(spacing: 8) {
            switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                Image(systemName: "location.fill")
                    .foregroundStyle(.green)
                if locationManager.currentLocation != nil {
                    Text("位置情報取得済み")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("位置情報を取得中...")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            case .denied, .restricted:
                Image(systemName: "location.slash.fill")
                    .foregroundStyle(.red)
                Text("位置情報が許可されていません")
                    .font(.caption)
                    .foregroundStyle(.red)
            default:
                Image(systemName: "location.circle")
                    .foregroundStyle(.gray)
                Text("位置情報の許可を待っています...")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }

    private var canStart: Bool {
        !playerName.trimmingCharacters(in: .whitespaces).isEmpty
            && locationManager.currentLocation != nil
    }

    private func startGame() {
        let name = playerName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let location = locationManager.currentLocation else { return }

        gameManager.currentPlayer = Player(name: name, team: selectedTeam)
        gameManager.setupGame(around: location.coordinate)
        showSetup = false
    }

    // MARK: - Main Game View

    private var mainGameView: some View {
        TabView(selection: $selectedTab) {
            // Map Tab
            GameMapView(gameManager: gameManager, locationManager: locationManager)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("マップ")
                }
                .tag(0)

            // AR Tab
            ARTerritoryView(gameManager: gameManager, locationManager: locationManager)
                .tabItem {
                    Image(systemName: "arkit")
                    Text("AR")
                }
                .tag(1)

            // Dashboard Tab
            NavigationStack {
                GameDashboardView(gameManager: gameManager)
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("状況")
            }
            .tag(2)

            // Leaderboard Tab
            NavigationStack {
                LeaderboardView(gameManager: gameManager)
            }
            .tabItem {
                Image(systemName: "trophy.fill")
                Text("順位")
            }
            .tag(3)
        }
        .tint(gameManager.currentPlayer.team.color)
    }
}
