import Foundation
import CoreLocation
import SwiftUI

/// Sample travel plan data for previewing and testing.
enum SampleData {

    // MARK: - Kyoto & Osaka 3-Day Trip

    static let kyotoOsakaPlan: TravelPlan = {
        let day1 = DayPlan(
            dayNumber: 1,
            title: "京都東エリア",
            destinations: [
                Destination(
                    name: "京都駅",
                    coordinate: CLLocationCoordinate2D(latitude: 34.9858, longitude: 135.7588),
                    category: .sightseeing
                ),
                Destination(
                    name: "伏見稲荷大社",
                    coordinate: CLLocationCoordinate2D(latitude: 34.9671, longitude: 135.7727),
                    category: .temple
                ),
                Destination(
                    name: "清水寺",
                    coordinate: CLLocationCoordinate2D(latitude: 34.9949, longitude: 135.7850),
                    category: .temple
                ),
                Destination(
                    name: "祇園・花見小路",
                    coordinate: CLLocationCoordinate2D(latitude: 35.0037, longitude: 135.7756),
                    category: .sightseeing
                ),
                Destination(
                    name: "錦市場",
                    coordinate: CLLocationCoordinate2D(latitude: 35.0050, longitude: 135.7649),
                    category: .shopping
                )
            ],
            color: DayPlan.colorForDay(1)
        )

        let day2 = DayPlan(
            dayNumber: 2,
            title: "京都北エリア",
            destinations: [
                Destination(
                    name: "金閣寺",
                    coordinate: CLLocationCoordinate2D(latitude: 35.0394, longitude: 135.7292),
                    category: .temple
                ),
                Destination(
                    name: "龍安寺",
                    coordinate: CLLocationCoordinate2D(latitude: 35.0345, longitude: 135.7185),
                    category: .temple
                ),
                Destination(
                    name: "嵐山竹林",
                    coordinate: CLLocationCoordinate2D(latitude: 35.0173, longitude: 135.6713),
                    category: .nature
                ),
                Destination(
                    name: "渡月橋",
                    coordinate: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.6781),
                    category: .sightseeing
                ),
                Destination(
                    name: "嵐山ランチ",
                    coordinate: CLLocationCoordinate2D(latitude: 35.0141, longitude: 135.6778),
                    category: .restaurant
                )
            ],
            color: DayPlan.colorForDay(2)
        )

        let day3 = DayPlan(
            dayNumber: 3,
            title: "大阪日帰り",
            destinations: [
                Destination(
                    name: "大阪城",
                    coordinate: CLLocationCoordinate2D(latitude: 34.6873, longitude: 135.5259),
                    category: .sightseeing
                ),
                Destination(
                    name: "道頓堀",
                    coordinate: CLLocationCoordinate2D(latitude: 34.6687, longitude: 135.5013),
                    category: .shopping
                ),
                Destination(
                    name: "黒門市場",
                    coordinate: CLLocationCoordinate2D(latitude: 34.6627, longitude: 135.5064),
                    category: .shopping
                ),
                Destination(
                    name: "通天閣",
                    coordinate: CLLocationCoordinate2D(latitude: 34.6525, longitude: 135.5063),
                    category: .sightseeing
                ),
                Destination(
                    name: "新大阪駅",
                    coordinate: CLLocationCoordinate2D(latitude: 34.7334, longitude: 135.5001),
                    category: .sightseeing
                )
            ],
            color: DayPlan.colorForDay(3)
        )

        return TravelPlan(
            title: "京都・大阪 3日間の旅",
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1))!,
            dayPlans: [day1, day2, day3]
        )
    }()

    // MARK: - Tokyo 2-Day Trip

    static let tokyoPlan: TravelPlan = {
        let day1 = DayPlan(
            dayNumber: 1,
            title: "東京定番コース",
            destinations: [
                Destination(
                    name: "東京駅",
                    coordinate: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
                    category: .sightseeing
                ),
                Destination(
                    name: "浅草寺",
                    coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7967),
                    category: .temple
                ),
                Destination(
                    name: "東京スカイツリー",
                    coordinate: CLLocationCoordinate2D(latitude: 35.7101, longitude: 139.8107),
                    category: .sightseeing
                ),
                Destination(
                    name: "秋葉原",
                    coordinate: CLLocationCoordinate2D(latitude: 35.7023, longitude: 139.7745),
                    category: .shopping
                ),
                Destination(
                    name: "新宿御苑",
                    coordinate: CLLocationCoordinate2D(latitude: 35.6852, longitude: 139.7100),
                    category: .nature
                )
            ],
            color: DayPlan.colorForDay(1)
        )

        let day2 = DayPlan(
            dayNumber: 2,
            title: "渋谷・原宿エリア",
            destinations: [
                Destination(
                    name: "明治神宮",
                    coordinate: CLLocationCoordinate2D(latitude: 35.6764, longitude: 139.6993),
                    category: .temple
                ),
                Destination(
                    name: "竹下通り",
                    coordinate: CLLocationCoordinate2D(latitude: 35.6702, longitude: 139.7026),
                    category: .shopping
                ),
                Destination(
                    name: "渋谷スクランブル交差点",
                    coordinate: CLLocationCoordinate2D(latitude: 35.6595, longitude: 139.7004),
                    category: .sightseeing
                ),
                Destination(
                    name: "お台場",
                    coordinate: CLLocationCoordinate2D(latitude: 35.6265, longitude: 139.7753),
                    category: .sightseeing
                )
            ],
            color: DayPlan.colorForDay(2)
        )

        return TravelPlan(
            title: "東京 2日間の旅",
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 10))!,
            dayPlans: [day1, day2]
        )
    }()

    static let allPlans: [TravelPlan] = [kyotoOsakaPlan, tokyoPlan]
}
