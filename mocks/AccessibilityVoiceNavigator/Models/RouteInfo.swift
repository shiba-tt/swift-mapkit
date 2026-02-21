import Foundation
import MapKit

/// 経路情報を保持するモデル
struct RouteInfo: Identifiable {
    let id = UUID()
    let route: MKRoute
    let steps: [NavigationStep]

    /// 経路の総距離（フォーマット済み）
    var totalDistanceText: String {
        let distance = route.distance
        if distance < 1000 {
            return "\(Int(distance))メートル"
        } else {
            let km = distance / 1000.0
            return String(format: "%.1fキロメートル", km)
        }
    }

    /// 経路の所要時間（フォーマット済み）
    var totalTimeText: String {
        let time = route.expectedTravelTime
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60

        if hours > 0 {
            return "約\(hours)時間\(minutes)分"
        } else {
            return "約\(minutes)分"
        }
    }

    /// 音声案内用の経路概要テキスト
    var voiceSummary: String {
        "目的地まで\(totalDistanceText)、所要時間は\(totalTimeText)です。ナビゲーションを開始します。"
    }

    /// MKRouteからNavigationStepの配列を生成
    static func createSteps(from route: MKRoute) -> [NavigationStep] {
        route.steps.compactMap { step in
            guard !step.instructions.isEmpty else { return nil }
            return NavigationStep(
                instruction: step.instructions,
                distance: step.distance,
                transportType: route.transportType,
                polyline: step.polyline,
                coordinate: step.polyline.coordinate
            )
        }
    }

    /// MKRouteからRouteInfoを生成
    static func from(route: MKRoute) -> RouteInfo {
        let steps = createSteps(from: route)
        return RouteInfo(route: route, steps: steps)
    }
}

/// ナビゲーション状態
enum NavigationState: Equatable {
    case idle
    case searching
    case routeFound
    case navigating
    case arrived
    case error(String)

    static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.searching, .searching),
             (.routeFound, .routeFound),
             (.navigating, .navigating),
             (.arrived, .arrived):
            return true
        case (.error(let l), .error(let r)):
            return l == r
        default:
            return false
        }
    }

    /// 状態の日本語表示テキスト
    var displayText: String {
        switch self {
        case .idle:
            return "目的地を検索してください"
        case .searching:
            return "経路を検索中..."
        case .routeFound:
            return "経路が見つかりました"
        case .navigating:
            return "ナビゲーション中"
        case .arrived:
            return "目的地に到着しました"
        case .error(let message):
            return "エラー: \(message)"
        }
    }
}
