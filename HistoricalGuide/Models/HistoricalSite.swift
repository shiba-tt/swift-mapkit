import Foundation
import CoreLocation
import MapKit

// MARK: - Historical Era

/// 歴史的時代区分
enum HistoricalEra: String, CaseIterable, Codable, Identifiable {
    case jomon = "縄文時代"
    case yayoi = "弥生時代"
    case kofun = "古墳時代"
    case asuka = "飛鳥時代"
    case nara = "奈良時代"
    case heian = "平安時代"
    case kamakura = "鎌倉時代"
    case muromachi = "室町時代"
    case azuchiMomoyama = "安土桃山時代"
    case edo = "江戸時代"
    case meiji = "明治時代"
    case taisho = "大正時代"
    case showa = "昭和時代"

    var id: String { rawValue }

    /// 時代の西暦範囲
    var yearRange: String {
        switch self {
        case .jomon: return "紀元前14000年〜紀元前300年"
        case .yayoi: return "紀元前300年〜300年"
        case .kofun: return "300年〜593年"
        case .asuka: return "593年〜710年"
        case .nara: return "710年〜794年"
        case .heian: return "794年〜1185年"
        case .kamakura: return "1185年〜1333年"
        case .muromachi: return "1333年〜1573年"
        case .azuchiMomoyama: return "1573年〜1603年"
        case .edo: return "1603年〜1868年"
        case .meiji: return "1868年〜1912年"
        case .taisho: return "1912年〜1926年"
        case .showa: return "1926年〜1989年"
        }
    }

    /// 時代のテーマカラー名（SF Symbolsで使用）
    var colorName: String {
        switch self {
        case .jomon, .yayoi, .kofun: return "brown"
        case .asuka, .nara: return "orange"
        case .heian: return "purple"
        case .kamakura, .muromachi: return "blue"
        case .azuchiMomoyama: return "red"
        case .edo: return "indigo"
        case .meiji, .taisho, .showa: return "green"
        }
    }
}

// MARK: - Site Category

/// 史跡のカテゴリ
enum SiteCategory: String, CaseIterable, Codable, Identifiable {
    case castle = "城"
    case temple = "寺院"
    case shrine = "神社"
    case garden = "庭園"
    case monument = "記念碑"
    case ruins = "遺跡"
    case residence = "邸宅"
    case bridge = "橋"
    case gate = "門"
    case other = "その他"

    var id: String { rawValue }

    /// カテゴリに対応するSF Symbolsアイコン名
    var iconName: String {
        switch self {
        case .castle: return "building.columns.fill"
        case .temple: return "house.lodge.fill"
        case .shrine: return "moon.stars.fill"
        case .garden: return "leaf.fill"
        case .monument: return "obelisk.fill"
        case .ruins: return "square.stack.3d.up.fill"
        case .residence: return "house.fill"
        case .bridge: return "road.lanes"
        case .gate: return "door.left.hand.open"
        case .other: return "mappin.circle.fill"
        }
    }
}

// MARK: - Historical Site

/// 歴史的建造物・史跡のデータモデル
struct HistoricalSite: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let nameReading: String
    let summary: String
    let description: String
    let era: HistoricalEra
    let category: SiteCategory
    let yearBuilt: String
    let latitude: Double
    let longitude: Double
    let address: String
    let historicalFigures: [String]
    let historicalEvents: [String]
    let arDescription: String
    let imageNames: [String]
    let isFavorite: Bool
    let visitingHours: String
    let admissionFee: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: HistoricalSite, rhs: HistoricalSite) -> Bool {
        lhs.id == rhs.id
    }

    init(
        id: UUID = UUID(),
        name: String,
        nameReading: String = "",
        summary: String,
        description: String,
        era: HistoricalEra,
        category: SiteCategory,
        yearBuilt: String,
        latitude: Double,
        longitude: Double,
        address: String,
        historicalFigures: [String] = [],
        historicalEvents: [String] = [],
        arDescription: String = "",
        imageNames: [String] = [],
        isFavorite: Bool = false,
        visitingHours: String = "",
        admissionFee: String = ""
    ) {
        self.id = id
        self.name = name
        self.nameReading = nameReading
        self.summary = summary
        self.description = description
        self.era = era
        self.category = category
        self.yearBuilt = yearBuilt
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.historicalFigures = historicalFigures
        self.historicalEvents = historicalEvents
        self.arDescription = arDescription
        self.imageNames = imageNames
        self.isFavorite = isFavorite
        self.visitingHours = visitingHours
        self.admissionFee = admissionFee
    }
}

// MARK: - Walking Route

/// 散策ルート
struct WalkingRoute: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let siteIDs: [UUID]
    let estimatedDurationMinutes: Int
    let distanceKilometers: Double
    let difficulty: RouteDifficulty

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        siteIDs: [UUID],
        estimatedDurationMinutes: Int,
        distanceKilometers: Double,
        difficulty: RouteDifficulty = .easy
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.siteIDs = siteIDs
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.distanceKilometers = distanceKilometers
        self.difficulty = difficulty
    }
}

/// ルートの難易度
enum RouteDifficulty: String, Codable, CaseIterable {
    case easy = "初級"
    case moderate = "中級"
    case hard = "上級"

    var iconName: String {
        switch self {
        case .easy: return "figure.walk"
        case .moderate: return "figure.hiking"
        case .hard: return "figure.climbing"
        }
    }
}
