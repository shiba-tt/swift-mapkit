import Foundation
import CoreLocation
import MapKit
import SwiftUI

// MARK: - Team

enum Team: String, CaseIterable, Codable, Identifiable {
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    case yellow = "Yellow"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .red: return "レッドチーム"
        case .blue: return "ブルーチーム"
        case .green: return "グリーンチーム"
        case .yellow: return "イエローチーム"
        }
    }

    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        }
    }

    var uiColor: UIColor {
        switch self {
        case .red: return .systemRed
        case .blue: return .systemBlue
        case .green: return .systemGreen
        case .yellow: return .systemYellow
        }
    }

    var icon: String {
        switch self {
        case .red: return "flame.fill"
        case .blue: return "drop.fill"
        case .green: return "leaf.fill"
        case .yellow: return "bolt.fill"
        }
    }
}

// MARK: - Player

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var team: Team
    var score: Int
    var capturedZoneCount: Int
    var totalCaptureTime: TimeInterval

    init(id: UUID = UUID(), name: String, team: Team) {
        self.id = id
        self.name = name
        self.team = team
        self.score = 0
        self.capturedZoneCount = 0
        self.totalCaptureTime = 0
    }
}

// MARK: - Zone Shape

enum ZoneShape: Codable {
    case circle(center: CodableCoordinate, radius: CLLocationDistance)
    case polygon(vertices: [CodableCoordinate])

    var centerCoordinate: CLLocationCoordinate2D {
        switch self {
        case .circle(let center, _):
            return center.coordinate
        case .polygon(let vertices):
            guard !vertices.isEmpty else {
                return CLLocationCoordinate2D(latitude: 0, longitude: 0)
            }
            let avgLat = vertices.map(\.latitude).reduce(0, +) / Double(vertices.count)
            let avgLon = vertices.map(\.longitude).reduce(0, +) / Double(vertices.count)
            return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
        }
    }
}

// MARK: - Codable CLLocationCoordinate2D

struct CodableCoordinate: Codable {
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Game Zone

struct GameZone: Identifiable, Codable {
    let id: UUID
    var name: String
    var shape: ZoneShape
    var ownerTeam: Team?
    var captureProgress: Double // 0.0 to 1.0
    var capturingTeam: Team?
    var pointsValue: Int
    var lastCapturedDate: Date?

    var isNeutral: Bool { ownerTeam == nil }
    var isBeingCaptured: Bool { capturingTeam != nil && captureProgress > 0 && captureProgress < 1.0 }

    init(
        id: UUID = UUID(),
        name: String,
        shape: ZoneShape,
        ownerTeam: Team? = nil,
        pointsValue: Int = 100
    ) {
        self.id = id
        self.name = name
        self.shape = shape
        self.ownerTeam = ownerTeam
        self.captureProgress = ownerTeam != nil ? 1.0 : 0.0
        self.capturingTeam = nil
        self.pointsValue = pointsValue
        self.lastCapturedDate = nil
    }

    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        switch shape {
        case .circle(let center, let radius):
            let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let pointLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return centerLocation.distance(from: pointLocation) <= radius

        case .polygon(let vertices):
            return isPointInPolygon(
                point: coordinate,
                polygon: vertices.map { $0.coordinate }
            )
        }
    }

    private func isPointInPolygon(
        point: CLLocationCoordinate2D,
        polygon: [CLLocationCoordinate2D]
    ) -> Bool {
        let n = polygon.count
        guard n >= 3 else { return false }

        var inside = false
        var j = n - 1

        for i in 0..<n {
            let xi = polygon[i].latitude, yi = polygon[i].longitude
            let xj = polygon[j].latitude, yj = polygon[j].longitude

            let intersect = ((yi > point.longitude) != (yj > point.longitude)) &&
                (point.latitude < (xj - xi) * (point.longitude - yi) / (yj - yi) + xi)

            if intersect { inside.toggle() }
            j = i
        }

        return inside
    }
}

// MARK: - Game State

enum GamePhase: String, Codable {
    case waiting = "待機中"
    case playing = "プレイ中"
    case finished = "終了"
}

struct GameState: Codable {
    var phase: GamePhase
    var zones: [GameZone]
    var players: [Player]
    var startTime: Date?
    var duration: TimeInterval
    var remainingTime: TimeInterval

    var teamScores: [Team: Int] {
        var scores: [Team: Int] = [:]
        for team in Team.allCases {
            let zonePoints = zones
                .filter { $0.ownerTeam == team }
                .reduce(0) { $0 + $1.pointsValue }
            let playerPoints = players
                .filter { $0.team == team }
                .reduce(0) { $0 + $1.score }
            scores[team] = zonePoints + playerPoints
        }
        return scores
    }

    var leadingTeam: Team? {
        teamScores.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Game Event

struct GameEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
    let team: Team?
    let type: EventType

    enum EventType {
        case capture
        case contestStart
        case contestEnd
        case gameStart
        case gameEnd
        case playerJoined
    }
}

// MARK: - Sample Data

extension GameZone {
    /// Generates sample zones around a given coordinate for demo/testing
    static func sampleZones(around center: CLLocationCoordinate2D) -> [GameZone] {
        let offset = 0.002 // ~200m

        return [
            GameZone(
                name: "中央広場",
                shape: .circle(
                    center: CodableCoordinate(center),
                    radius: 80
                ),
                pointsValue: 200
            ),
            GameZone(
                name: "北の砦",
                shape: .circle(
                    center: CodableCoordinate(
                        CLLocationCoordinate2D(
                            latitude: center.latitude + offset,
                            longitude: center.longitude
                        )
                    ),
                    radius: 50
                ),
                pointsValue: 100
            ),
            GameZone(
                name: "南の塔",
                shape: .circle(
                    center: CodableCoordinate(
                        CLLocationCoordinate2D(
                            latitude: center.latitude - offset,
                            longitude: center.longitude
                        )
                    ),
                    radius: 50
                ),
                pointsValue: 100
            ),
            GameZone(
                name: "東の森",
                shape: .polygon(vertices: [
                    CodableCoordinate(latitude: center.latitude + offset * 0.5, longitude: center.longitude + offset),
                    CodableCoordinate(latitude: center.latitude + offset, longitude: center.longitude + offset * 1.5),
                    CodableCoordinate(latitude: center.latitude + offset * 0.5, longitude: center.longitude + offset * 2),
                    CodableCoordinate(latitude: center.latitude, longitude: center.longitude + offset * 1.5),
                    CodableCoordinate(latitude: center.latitude, longitude: center.longitude + offset),
                ]),
                pointsValue: 150
            ),
            GameZone(
                name: "西の湖",
                shape: .polygon(vertices: [
                    CodableCoordinate(latitude: center.latitude + offset * 0.3, longitude: center.longitude - offset),
                    CodableCoordinate(latitude: center.latitude + offset * 0.8, longitude: center.longitude - offset * 1.3),
                    CodableCoordinate(latitude: center.latitude + offset * 0.3, longitude: center.longitude - offset * 1.8),
                    CodableCoordinate(latitude: center.latitude - offset * 0.3, longitude: center.longitude - offset * 1.5),
                    CodableCoordinate(latitude: center.latitude - offset * 0.3, longitude: center.longitude - offset),
                ]),
                pointsValue: 150
            ),
            GameZone(
                name: "秘密の庭",
                shape: .circle(
                    center: CodableCoordinate(
                        CLLocationCoordinate2D(
                            latitude: center.latitude - offset * 0.8,
                            longitude: center.longitude + offset * 1.2
                        )
                    ),
                    radius: 40
                ),
                ownerTeam: .red,
                pointsValue: 120
            ),
        ]
    }
}
