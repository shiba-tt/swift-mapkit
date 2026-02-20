import Foundation
import MapKit

// MARK: - ランドマークデータ

struct Landmark: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let systemImage: String
    let category: Category

    enum Category: String, CaseIterable {
        case temple = "寺社"
        case tower = "タワー"
        case park = "公園"
        case station = "駅"
        case shopping = "商業施設"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Landmark, rhs: Landmark) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 都市データ

struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan

    var region: MKCoordinateRegion {
        MKCoordinateRegion(center: coordinate, span: span)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - サンプルデータ定義

enum SampleData {

    // MARK: 都市

    static let tokyo = City(
        name: "東京",
        coordinate: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    static let osaka = City(
        name: "大阪",
        coordinate: CLLocationCoordinate2D(latitude: 34.6937, longitude: 135.5023),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    static let kyoto = City(
        name: "京都",
        coordinate: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    static let sapporo = City(
        name: "札幌",
        coordinate: CLLocationCoordinate2D(latitude: 43.0618, longitude: 141.3545),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    static let fukuoka = City(
        name: "福岡",
        coordinate: CLLocationCoordinate2D(latitude: 33.5904, longitude: 130.4017),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    static let cities: [City] = [tokyo, osaka, kyoto, sapporo, fukuoka]

    // MARK: 東京のランドマーク

    static let tokyoLandmarks: [Landmark] = [
        Landmark(
            name: "東京タワー",
            coordinate: CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454),
            systemImage: "antenna.radiowaves.left.and.right",
            category: .tower
        ),
        Landmark(
            name: "東京スカイツリー",
            coordinate: CLLocationCoordinate2D(latitude: 35.7101, longitude: 139.8107),
            systemImage: "building.2",
            category: .tower
        ),
        Landmark(
            name: "浅草寺",
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7967),
            systemImage: "building.columns",
            category: .temple
        ),
        Landmark(
            name: "明治神宮",
            coordinate: CLLocationCoordinate2D(latitude: 35.6764, longitude: 139.6993),
            systemImage: "leaf",
            category: .temple
        ),
        Landmark(
            name: "上野公園",
            coordinate: CLLocationCoordinate2D(latitude: 35.7146, longitude: 139.7732),
            systemImage: "tree",
            category: .park
        ),
        Landmark(
            name: "新宿御苑",
            coordinate: CLLocationCoordinate2D(latitude: 35.6852, longitude: 139.7100),
            systemImage: "leaf.circle",
            category: .park
        ),
        Landmark(
            name: "東京駅",
            coordinate: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            systemImage: "tram",
            category: .station
        ),
        Landmark(
            name: "渋谷スクランブルスクエア",
            coordinate: CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016),
            systemImage: "cart",
            category: .shopping
        ),
    ]

    // MARK: 皇居エリアのポリゴン座標

    static let imperialPalaceCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 35.6870, longitude: 139.7500),
        CLLocationCoordinate2D(latitude: 35.6870, longitude: 139.7580),
        CLLocationCoordinate2D(latitude: 35.6830, longitude: 139.7610),
        CLLocationCoordinate2D(latitude: 35.6780, longitude: 139.7600),
        CLLocationCoordinate2D(latitude: 35.6760, longitude: 139.7540),
        CLLocationCoordinate2D(latitude: 35.6780, longitude: 139.7480),
        CLLocationCoordinate2D(latitude: 35.6830, longitude: 139.7470),
    ]

    // MARK: 山手線ルート（簡略版）

    static let yamanoteLineCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671), // 東京
        CLLocationCoordinate2D(latitude: 35.6917, longitude: 139.7703), // 神田
        CLLocationCoordinate2D(latitude: 35.6984, longitude: 139.7731), // 秋葉原
        CLLocationCoordinate2D(latitude: 35.7079, longitude: 139.7745), // 御徒町
        CLLocationCoordinate2D(latitude: 35.7141, longitude: 139.7774), // 上野
        CLLocationCoordinate2D(latitude: 35.7281, longitude: 139.7710), // 日暮里
        CLLocationCoordinate2D(latitude: 35.7381, longitude: 139.7249), // 田端
        CLLocationCoordinate2D(latitude: 35.7365, longitude: 139.7187), // 駒込
        CLLocationCoordinate2D(latitude: 35.7301, longitude: 139.7111), // 巣鴨
        CLLocationCoordinate2D(latitude: 35.7264, longitude: 139.7163), // 大塚
        CLLocationCoordinate2D(latitude: 35.7295, longitude: 139.7109), // 池袋
        CLLocationCoordinate2D(latitude: 35.7215, longitude: 139.6944), // 目白
        CLLocationCoordinate2D(latitude: 35.7126, longitude: 139.6859), // 高田馬場
        CLLocationCoordinate2D(latitude: 35.7003, longitude: 139.7005), // 新大久保
        CLLocationCoordinate2D(latitude: 35.6896, longitude: 139.7006), // 新宿
        CLLocationCoordinate2D(latitude: 35.6814, longitude: 139.7020), // 代々木
        CLLocationCoordinate2D(latitude: 35.6702, longitude: 139.7026), // 原宿
        CLLocationCoordinate2D(latitude: 35.6585, longitude: 139.7016), // 渋谷
        CLLocationCoordinate2D(latitude: 35.6467, longitude: 139.7103), // 恵比寿
        CLLocationCoordinate2D(latitude: 35.6334, longitude: 139.7155), // 目黒
        CLLocationCoordinate2D(latitude: 35.6197, longitude: 139.7254), // 五反田
        CLLocationCoordinate2D(latitude: 35.6087, longitude: 139.7307), // 大崎
        CLLocationCoordinate2D(latitude: 35.6299, longitude: 139.7414), // 品川
        CLLocationCoordinate2D(latitude: 35.6455, longitude: 139.7478), // 田町
        CLLocationCoordinate2D(latitude: 35.6555, longitude: 139.7512), // 浜松町
        CLLocationCoordinate2D(latitude: 35.6659, longitude: 139.7584), // 新橋
        CLLocationCoordinate2D(latitude: 35.6753, longitude: 139.7639), // 有楽町
        CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671), // 東京（閉じる）
    ]
}
