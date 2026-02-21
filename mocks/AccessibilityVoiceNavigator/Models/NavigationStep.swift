import Foundation
import MapKit

/// ナビゲーションの各ステップを表すモデル
struct NavigationStep: Identifiable, Equatable {
    let id = UUID()
    let instruction: String
    let distance: CLLocationDistance
    let transportType: MKDirectionsTransportType
    let polyline: MKPolyline?
    let coordinate: CLLocationCoordinate2D

    /// 音声読み上げ用のテキスト（日本語）
    var voiceText: String {
        let distanceText = formattedDistance
        return "\(distanceText)先、\(instruction)"
    }

    /// 距離を読みやすい形式にフォーマット
    var formattedDistance: String {
        if distance < 100 {
            return "\(Int(distance))メートル"
        } else if distance < 1000 {
            let rounded = Int(round(distance / 10) * 10)
            return "\(rounded)メートル"
        } else {
            let km = distance / 1000.0
            return String(format: "%.1fキロメートル", km)
        }
    }

    static func == (lhs: NavigationStep, rhs: NavigationStep) -> Bool {
        lhs.id == rhs.id
    }
}

/// 検索結果のアイテム
struct SearchResultItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem

    /// VoiceOver用のアクセシビリティラベル
    var accessibilityLabel: String {
        "\(name)、\(address)"
    }

    static func == (lhs: SearchResultItem, rhs: SearchResultItem) -> Bool {
        lhs.id == rhs.id
    }
}
