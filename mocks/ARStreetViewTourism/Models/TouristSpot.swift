import Foundation
import CoreLocation
import MapKit

/// 観光スポットのデータモデル
struct TouristSpot: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nameJapanese: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let category: Category

    enum Category: String, CaseIterable, Hashable {
        case temple = "寺院"
        case shrine = "神社"
        case landmark = "ランドマーク"
        case nature = "自然"
        case modern = "現代建築"

        var systemImage: String {
            switch self {
            case .temple: return "building.columns"
            case .shrine: return "house.lodge"
            case .landmark: return "star.fill"
            case .nature: return "leaf.fill"
            case .modern: return "building.2"
            }
        }

        var color: String {
            switch self {
            case .temple: return "orange"
            case .shrine: return "red"
            case .landmark: return "purple"
            case .nature: return "green"
            case .modern: return "blue"
            }
        }
    }

    static func == (lhs: TouristSpot, rhs: TouristSpot) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - サンプル観光スポットデータ（東京・京都）

extension TouristSpot {
    static let sampleSpots: [TouristSpot] = [
        // 東京エリア
        TouristSpot(
            name: "Senso-ji Temple",
            nameJapanese: "浅草寺",
            description: "東京最古の寺院。雷門の大提灯が象徴的で、仲見世通りには土産物店が並びます。",
            coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7967),
            category: .temple
        ),
        TouristSpot(
            name: "Tokyo Tower",
            nameJapanese: "東京タワー",
            description: "1958年完成の電波塔。高さ333mで、展望台からは東京の絶景パノラマが楽しめます。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454),
            category: .landmark
        ),
        TouristSpot(
            name: "Meiji Shrine",
            nameJapanese: "明治神宮",
            description: "明治天皇と昭憲皇太后を祀る神社。広大な森に囲まれた都会のオアシスです。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6764, longitude: 139.6993),
            category: .shrine
        ),
        TouristSpot(
            name: "Shibuya Crossing",
            nameJapanese: "渋谷スクランブル交差点",
            description: "世界で最も混雑する交差点の一つ。一度に最大3000人が横断する光景は圧巻です。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6595, longitude: 139.7004),
            category: .landmark
        ),
        TouristSpot(
            name: "Shinjuku Gyoen",
            nameJapanese: "新宿御苑",
            description: "日本庭園・フランス式庭園・イギリス式庭園の3つの様式を持つ広大な国民公園です。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6852, longitude: 139.7100),
            category: .nature
        ),
        TouristSpot(
            name: "Tokyo Skytree",
            nameJapanese: "東京スカイツリー",
            description: "高さ634mの世界一高い自立式電波塔。展望デッキから関東平野を一望できます。",
            coordinate: CLLocationCoordinate2D(latitude: 35.7101, longitude: 139.8107),
            category: .modern
        ),
        // 京都エリア
        TouristSpot(
            name: "Kinkaku-ji",
            nameJapanese: "金閣寺",
            description: "金箔で覆われた舎利殿が鏡湖池に映る姿は日本を代表する景観です。",
            coordinate: CLLocationCoordinate2D(latitude: 35.0394, longitude: 135.7292),
            category: .temple
        ),
        TouristSpot(
            name: "Fushimi Inari Taisha",
            nameJapanese: "伏見稲荷大社",
            description: "千本鳥居で有名な全国約3万の稲荷神社の総本宮。稲荷山全体が信仰の対象です。",
            coordinate: CLLocationCoordinate2D(latitude: 34.9671, longitude: 135.7727),
            category: .shrine
        ),
        TouristSpot(
            name: "Arashiyama Bamboo Grove",
            nameJapanese: "嵐山竹林の小径",
            description: "天に向かって真っすぐ伸びる竹が両側に並ぶ幻想的な小道。風の音も美しい。",
            coordinate: CLLocationCoordinate2D(latitude: 35.0170, longitude: 135.6713),
            category: .nature
        ),
        TouristSpot(
            name: "Kiyomizu-dera",
            nameJapanese: "清水寺",
            description: "「清水の舞台」で有名な世界遺産。崖に張り出した本堂からの京都市街の眺望は見事です。",
            coordinate: CLLocationCoordinate2D(latitude: 34.9949, longitude: 135.7850),
            category: .temple
        ),
    ]
}
