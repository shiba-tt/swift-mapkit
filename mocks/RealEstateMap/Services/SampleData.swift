import CoreLocation

/// サンプルデータ（東京・目黒〜渋谷エリア）
enum SampleData {

    // MARK: - 駅データ

    static let stations: [Station] = [
        Station(
            name: "中目黒",
            coordinate: CLLocationCoordinate2D(latitude: 35.6440, longitude: 139.6989),
            line: "東急東横線・日比谷線"
        ),
        Station(
            name: "恵比寿",
            coordinate: CLLocationCoordinate2D(latitude: 35.6467, longitude: 139.7100),
            line: "JR山手線・日比谷線"
        ),
        Station(
            name: "代官山",
            coordinate: CLLocationCoordinate2D(latitude: 35.6486, longitude: 139.7030),
            line: "東急東横線"
        ),
    ]

    // MARK: - 学区データ

    static let schoolDistricts: [SchoolDistrict] = [
        // 中目黒小学校学区
        SchoolDistrict(
            name: "中目黒小学校",
            level: .elementary,
            boundary: [
                CLLocationCoordinate2D(latitude: 35.6470, longitude: 139.6950),
                CLLocationCoordinate2D(latitude: 35.6470, longitude: 139.7020),
                CLLocationCoordinate2D(latitude: 35.6430, longitude: 139.7040),
                CLLocationCoordinate2D(latitude: 35.6410, longitude: 139.7010),
                CLLocationCoordinate2D(latitude: 35.6410, longitude: 139.6950),
                CLLocationCoordinate2D(latitude: 35.6440, longitude: 139.6930),
            ]
        ),
        // 東山小学校学区
        SchoolDistrict(
            name: "東山小学校",
            level: .elementary,
            boundary: [
                CLLocationCoordinate2D(latitude: 35.6500, longitude: 139.6900),
                CLLocationCoordinate2D(latitude: 35.6500, longitude: 139.6960),
                CLLocationCoordinate2D(latitude: 35.6470, longitude: 139.6980),
                CLLocationCoordinate2D(latitude: 35.6450, longitude: 139.6950),
                CLLocationCoordinate2D(latitude: 35.6450, longitude: 139.6890),
                CLLocationCoordinate2D(latitude: 35.6480, longitude: 139.6880),
            ]
        ),
        // 目黒第一中学校学区
        SchoolDistrict(
            name: "目黒第一中学校",
            level: .juniorHigh,
            boundary: [
                CLLocationCoordinate2D(latitude: 35.6500, longitude: 139.6920),
                CLLocationCoordinate2D(latitude: 35.6500, longitude: 139.7050),
                CLLocationCoordinate2D(latitude: 35.6430, longitude: 139.7060),
                CLLocationCoordinate2D(latitude: 35.6400, longitude: 139.7010),
                CLLocationCoordinate2D(latitude: 35.6400, longitude: 139.6930),
                CLLocationCoordinate2D(latitude: 35.6450, longitude: 139.6900),
            ]
        ),
    ]

    // MARK: - 物件データ

    static let properties: [Property] = [
        Property(
            name: "パークハウス中目黒",
            address: "東京都目黒区中目黒3-5-1",
            coordinate: CLLocationCoordinate2D(latitude: 35.6435, longitude: 139.6975),
            price: 8980,
            layout: "3LDK",
            area: 72.5,
            buildYear: 2020,
            nearestStation: "中目黒",
            walkMinutes: 5
        ),
        Property(
            name: "ブリリア恵比寿ガーデン",
            address: "東京都渋谷区恵比寿南1-2-3",
            coordinate: CLLocationCoordinate2D(latitude: 35.6455, longitude: 139.7085),
            price: 12500,
            layout: "2LDK",
            area: 65.3,
            buildYear: 2022,
            nearestStation: "恵比寿",
            walkMinutes: 3
        ),
        Property(
            name: "代官山アドレス",
            address: "東京都渋谷区代官山町17-6",
            coordinate: CLLocationCoordinate2D(latitude: 35.6490, longitude: 139.7025),
            price: 15800,
            layout: "3LDK",
            area: 85.0,
            buildYear: 2018,
            nearestStation: "代官山",
            walkMinutes: 2
        ),
        Property(
            name: "プラウド中目黒",
            address: "東京都目黒区上目黒2-8-10",
            coordinate: CLLocationCoordinate2D(latitude: 35.6460, longitude: 139.6960),
            price: 7480,
            layout: "2LDK",
            area: 58.2,
            buildYear: 2019,
            nearestStation: "中目黒",
            walkMinutes: 7
        ),
        Property(
            name: "ザ・パークハウス恵比寿",
            address: "東京都渋谷区恵比寿3-1-5",
            coordinate: CLLocationCoordinate2D(latitude: 35.6480, longitude: 139.7120),
            price: 19800,
            layout: "4LDK",
            area: 105.0,
            buildYear: 2023,
            nearestStation: "恵比寿",
            walkMinutes: 6
        ),
        Property(
            name: "リビオ中目黒レジデンス",
            address: "東京都目黒区中目黒1-4-8",
            coordinate: CLLocationCoordinate2D(latitude: 35.6445, longitude: 139.7005),
            price: 6980,
            layout: "1LDK",
            area: 45.8,
            buildYear: 2021,
            nearestStation: "中目黒",
            walkMinutes: 4
        ),
    ]
}
