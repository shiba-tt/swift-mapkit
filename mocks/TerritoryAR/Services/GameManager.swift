import Foundation
import CoreLocation
import Combine
import SwiftUI

@MainActor
final class GameManager: ObservableObject {
    // MARK: - Published State

    @Published var gameState: GameState
    @Published var currentPlayer: Player
    @Published var events: [GameEvent] = []
    @Published var currentZone: GameZone?
    @Published var nearbyZones: [GameZone] = []

    // MARK: - Private

    private var captureTimer: Timer?
    private var gameTimer: Timer?
    private var scoreTimer: Timer?

    private let captureRate: Double = 0.05 // 5% per tick
    private let captureTickInterval: TimeInterval = 0.5
    private let nearbyRadius: CLLocationDistance = 500

    // MARK: - Init

    init(playerName: String = "プレイヤー", team: Team = .blue) {
        let player = Player(name: playerName, team: team)
        self.currentPlayer = player
        self.gameState = GameState(
            phase: .waiting,
            zones: [],
            players: [player],
            startTime: nil,
            duration: 600, // 10 minutes
            remainingTime: 600
        )
    }

    // MARK: - Game Lifecycle

    func setupGame(around center: CLLocationCoordinate2D) {
        let zones = GameZone.sampleZones(around: center)
        gameState.zones = zones
        addEvent("ゲームゾーンが生成されました", type: .gameStart)
    }

    func startGame() {
        guard gameState.phase == .waiting else { return }
        gameState.phase = .playing
        gameState.startTime = Date()
        addEvent("ゲーム開始！", type: .gameStart)

        startGameTimer()
        startScoreTimer()
    }

    func endGame() {
        gameState.phase = .finished
        captureTimer?.invalidate()
        captureTimer = nil
        gameTimer?.invalidate()
        gameTimer = nil
        scoreTimer?.invalidate()
        scoreTimer = nil

        if let winner = gameState.leadingTeam {
            addEvent("\(winner.displayName)の勝利！", team: winner, type: .gameEnd)
        } else {
            addEvent("ゲーム終了 - 引き分け！", type: .gameEnd)
        }
    }

    func resetGame(around center: CLLocationCoordinate2D) {
        endGame()
        let player = Player(name: currentPlayer.name, team: currentPlayer.team)
        self.currentPlayer = player
        self.gameState = GameState(
            phase: .waiting,
            zones: [],
            players: [player],
            startTime: nil,
            duration: 600,
            remainingTime: 600
        )
        self.events = []
        self.currentZone = nil
        self.nearbyZones = []
        setupGame(around: center)
    }

    // MARK: - Location Updates

    func updatePlayerLocation(_ coordinate: CLLocationCoordinate2D) {
        guard gameState.phase == .playing else { return }

        // Find zone player is currently inside
        let insideZone = gameState.zones.first { $0.contains(coordinate: coordinate) }

        // Update nearby zones
        nearbyZones = gameState.zones.filter { zone in
            let zoneCenter = zone.shape.centerCoordinate
            let distance = CLLocation(latitude: zoneCenter.latitude, longitude: zoneCenter.longitude)
                .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            return distance <= nearbyRadius
        }

        if let zone = insideZone, zone.id != currentZone?.id {
            enterZone(zone)
        } else if insideZone == nil && currentZone != nil {
            leaveZone()
        }
    }

    // MARK: - Zone Capture

    private func enterZone(_ zone: GameZone) {
        currentZone = zone

        if zone.ownerTeam != currentPlayer.team {
            startCapturing(zone: zone)
            addEvent(
                "\(currentPlayer.name)が\(zone.name)の占領を開始",
                team: currentPlayer.team,
                type: .contestStart
            )
        }
    }

    private func leaveZone() {
        if let zone = currentZone {
            stopCapturing()
            // Reset capture progress if incomplete
            if let idx = gameState.zones.firstIndex(where: { $0.id == zone.id }) {
                if gameState.zones[idx].captureProgress < 1.0 && gameState.zones[idx].capturingTeam == currentPlayer.team {
                    gameState.zones[idx].captureProgress = 0
                    gameState.zones[idx].capturingTeam = nil
                }
            }
            addEvent(
                "\(currentPlayer.name)が\(zone.name)から離脱",
                team: currentPlayer.team,
                type: .contestEnd
            )
        }
        currentZone = nil
    }

    private func startCapturing(zone: GameZone) {
        stopCapturing()

        captureTimer = Timer.scheduledTimer(withTimeInterval: captureTickInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.captureTickForCurrentZone()
            }
        }
    }

    private func stopCapturing() {
        captureTimer?.invalidate()
        captureTimer = nil
    }

    private func captureTickForCurrentZone() {
        guard let zone = currentZone,
              let idx = gameState.zones.firstIndex(where: { $0.id == zone.id }) else {
            return
        }

        var z = gameState.zones[idx]

        if z.ownerTeam == currentPlayer.team {
            // Already owned
            stopCapturing()
            return
        }

        z.capturingTeam = currentPlayer.team

        if z.ownerTeam != nil && z.ownerTeam != currentPlayer.team {
            // Decrement owner's hold first
            z.captureProgress -= captureRate
            if z.captureProgress <= 0 {
                z.captureProgress = 0
                z.ownerTeam = nil
                addEvent("\(z.name)が中立に戻りました", type: .contestEnd)
            }
        } else {
            // Capture neutral zone
            z.captureProgress += captureRate
            if z.captureProgress >= 1.0 {
                z.captureProgress = 1.0
                z.ownerTeam = currentPlayer.team
                z.capturingTeam = nil
                z.lastCapturedDate = Date()
                currentPlayer.capturedZoneCount += 1
                currentPlayer.score += z.pointsValue

                addEvent(
                    "\(currentPlayer.name)が\(z.name)を占領しました！(+\(z.pointsValue)pt)",
                    team: currentPlayer.team,
                    type: .capture
                )
                stopCapturing()
            }
        }

        gameState.zones[idx] = z
        currentZone = z
    }

    // MARK: - Timers

    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.gameState.remainingTime -= 1
                if self.gameState.remainingTime <= 0 {
                    self.gameState.remainingTime = 0
                    self.endGame()
                }
            }
        }
    }

    private func startScoreTimer() {
        // Award points for held zones every 10 seconds
        scoreTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                let heldZones = self.gameState.zones.filter { $0.ownerTeam == self.currentPlayer.team }
                let bonus = heldZones.count * 10
                if bonus > 0 {
                    self.currentPlayer.score += bonus
                }
            }
        }
    }

    // MARK: - Events

    private func addEvent(_ message: String, team: Team? = nil, type: GameEvent.EventType) {
        let event = GameEvent(timestamp: Date(), message: message, team: team, type: type)
        events.insert(event, at: 0)
        if events.count > 50 {
            events = Array(events.prefix(50))
        }
    }

    // MARK: - Formatting

    var remainingTimeFormatted: String {
        let minutes = Int(gameState.remainingTime) / 60
        let seconds = Int(gameState.remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
