import Foundation
import MapKit
import Combine

/// 交通データサービス - リアルタイム交通データのシミュレーション
final class TrafficDataService: ObservableObject {

    static let shared = TrafficDataService()

    /// 更新間隔（秒）
    private let updateInterval: TimeInterval = 15.0
    private var timer: Timer?

    // MARK: - 東京エリアの主要道路データ

    /// メインルート: 渋谷 → 新宿（明治通り経由）
    func generateMainRoute() -> TrafficRoute {
        let segments = [
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016), // 渋谷駅
                    CLLocationCoordinate2D(latitude: 35.6610, longitude: 139.7020),
                    CLLocationCoordinate2D(latitude: 35.6648, longitude: 139.7030), // 原宿方面
                ],
                trafficLevel: randomTrafficLevel(bias: .moderate),
                roadName: "明治通り（渋谷〜原宿）"
            ),
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6648, longitude: 139.7030),
                    CLLocationCoordinate2D(latitude: 35.6700, longitude: 139.7050),
                    CLLocationCoordinate2D(latitude: 35.6750, longitude: 139.7070), // 千駄ヶ谷方面
                ],
                trafficLevel: randomTrafficLevel(bias: .heavy),
                roadName: "明治通り（原宿〜千駄ヶ谷）"
            ),
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6750, longitude: 139.7070),
                    CLLocationCoordinate2D(latitude: 35.6800, longitude: 139.7040),
                    CLLocationCoordinate2D(latitude: 35.6850, longitude: 139.7010),
                    CLLocationCoordinate2D(latitude: 35.6896, longitude: 139.7006), // 新宿三丁目
                ],
                trafficLevel: randomTrafficLevel(bias: .light),
                roadName: "明治通り（千駄ヶ谷〜新宿）"
            ),
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6896, longitude: 139.7006),
                    CLLocationCoordinate2D(latitude: 35.6920, longitude: 139.6990),
                    CLLocationCoordinate2D(latitude: 35.6938, longitude: 139.7005), // 新宿駅
                ],
                trafficLevel: randomTrafficLevel(bias: .moderate),
                roadName: "新宿通り"
            ),
        ]

        return TrafficRoute(name: "渋谷→新宿（明治通り）", segments: segments)
    }

    /// 迂回ルート: 渋谷 → 新宿（山手通り・甲州街道経由）
    func generateDetourRoute() -> TrafficRoute {
        let segments = [
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016), // 渋谷駅
                    CLLocationCoordinate2D(latitude: 35.6590, longitude: 139.6950),
                    CLLocationCoordinate2D(latitude: 35.6610, longitude: 139.6880), // 山手通り方面
                ],
                trafficLevel: randomTrafficLevel(bias: .free),
                roadName: "道玄坂〜山手通り"
            ),
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6610, longitude: 139.6880),
                    CLLocationCoordinate2D(latitude: 35.6660, longitude: 139.6850),
                    CLLocationCoordinate2D(latitude: 35.6720, longitude: 139.6830),
                    CLLocationCoordinate2D(latitude: 35.6780, longitude: 139.6810), // 初台方面
                ],
                trafficLevel: randomTrafficLevel(bias: .light),
                roadName: "山手通り"
            ),
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6780, longitude: 139.6810),
                    CLLocationCoordinate2D(latitude: 35.6810, longitude: 139.6830),
                    CLLocationCoordinate2D(latitude: 35.6850, longitude: 139.6870), // 幡ヶ谷方面
                ],
                trafficLevel: randomTrafficLevel(bias: .free),
                roadName: "甲州街道（初台〜幡ヶ谷）"
            ),
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6850, longitude: 139.6870),
                    CLLocationCoordinate2D(latitude: 35.6880, longitude: 139.6910),
                    CLLocationCoordinate2D(latitude: 35.6910, longitude: 139.6950),
                    CLLocationCoordinate2D(latitude: 35.6938, longitude: 139.7005), // 新宿駅
                ],
                trafficLevel: randomTrafficLevel(bias: .light),
                roadName: "甲州街道（幡ヶ谷〜新宿）"
            ),
        ]

        return TrafficRoute(name: "渋谷→新宿（山手通り迂回）", segments: segments, isDetour: true)
    }

    /// 首都高速ルート
    func generateExpresswayRoute() -> TrafficRoute {
        let segments = [
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016), // 渋谷入口
                    CLLocationCoordinate2D(latitude: 35.6600, longitude: 139.7100),
                    CLLocationCoordinate2D(latitude: 35.6630, longitude: 139.7150), // 外苑方面
                ],
                trafficLevel: randomTrafficLevel(bias: .heavy),
                roadName: "首都高3号渋谷線"
            ),
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6630, longitude: 139.7150),
                    CLLocationCoordinate2D(latitude: 35.6720, longitude: 139.7180),
                    CLLocationCoordinate2D(latitude: 35.6800, longitude: 139.7160), // 外苑〜四谷
                ],
                trafficLevel: randomTrafficLevel(bias: .moderate),
                roadName: "首都高4号新宿線"
            ),
            TrafficSegment(
                coordinates: [
                    CLLocationCoordinate2D(latitude: 35.6800, longitude: 139.7160),
                    CLLocationCoordinate2D(latitude: 35.6860, longitude: 139.7120),
                    CLLocationCoordinate2D(latitude: 35.6938, longitude: 139.7005), // 新宿出口
                ],
                trafficLevel: randomTrafficLevel(bias: .heavy),
                roadName: "首都高4号新宿線（新宿出口）"
            ),
        ]

        return TrafficRoute(name: "渋谷→新宿（首都高速）", segments: segments)
    }

    /// 渋滞ポイントを生成
    func generateCongestionPoints() -> [CongestionPoint] {
        [
            CongestionPoint(
                coordinate: CLLocationCoordinate2D(latitude: 35.6648, longitude: 139.7030),
                trafficLevel: .heavy,
                roadName: "原宿交差点",
                description: "原宿駅前の歩行者横断による渋滞"
            ),
            CongestionPoint(
                coordinate: CLLocationCoordinate2D(latitude: 35.6750, longitude: 139.7070),
                trafficLevel: .moderate,
                roadName: "千駄ヶ谷交差点",
                description: "工事規制のため片側通行"
            ),
            CongestionPoint(
                coordinate: CLLocationCoordinate2D(latitude: 35.6896, longitude: 139.7006),
                trafficLevel: .heavy,
                roadName: "新宿三丁目",
                description: "交差点付近で事故発生"
            ),
            CongestionPoint(
                coordinate: CLLocationCoordinate2D(latitude: 35.6630, longitude: 139.7150),
                trafficLevel: .moderate,
                roadName: "外苑前",
                description: "合流地点の渋滞"
            ),
            CongestionPoint(
                coordinate: CLLocationCoordinate2D(latitude: 35.6590, longitude: 139.6950),
                trafficLevel: randomTrafficLevel(bias: .light),
                roadName: "道玄坂上",
                description: "通常の交通量"
            ),
        ]
    }

    // MARK: - データ更新

    /// 全ルートを再生成（リアルタイムシミュレーション）
    func refreshAllData() -> (routes: [TrafficRoute], congestionPoints: [CongestionPoint]) {
        let routes = [
            generateMainRoute(),
            generateDetourRoute(),
            generateExpresswayRoute(),
        ]
        let points = generateCongestionPoints()
        return (routes, points)
    }

    /// タイマーで定期更新開始
    func startAutoRefresh(onUpdate: @escaping ([TrafficRoute], [CongestionPoint]) -> Void) {
        stopAutoRefresh()
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            let data = self.refreshAllData()
            DispatchQueue.main.async {
                onUpdate(data.routes, data.congestionPoints)
            }
        }
    }

    /// 定期更新停止
    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - ヘルパー

    /// バイアス付きランダム交通レベル生成
    private func randomTrafficLevel(bias: TrafficLevel) -> TrafficLevel {
        let weights: [TrafficLevel: [Double]] = [
            .free:     [0.50, 0.30, 0.15, 0.04, 0.01],
            .light:    [0.25, 0.40, 0.20, 0.10, 0.05],
            .moderate: [0.10, 0.20, 0.40, 0.20, 0.10],
            .heavy:    [0.05, 0.10, 0.20, 0.45, 0.20],
            .blocked:  [0.02, 0.08, 0.15, 0.25, 0.50],
        ]

        let probabilities = weights[bias] ?? [0.2, 0.2, 0.2, 0.2, 0.2]
        let random = Double.random(in: 0...1)
        var cumulative = 0.0

        for (index, probability) in probabilities.enumerated() {
            cumulative += probability
            if random <= cumulative {
                return TrafficLevel.allCases[index]
            }
        }

        return bias
    }
}
