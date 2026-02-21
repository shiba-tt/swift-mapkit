import Foundation
import MapKit

/// アニメ・映画・ドラマなどの聖地巡礼スポット
struct PilgrimageSpot: Identifiable, Hashable {
    let id: UUID
    let name: String
    let workTitle: String        // 作品タイトル
    let sceneName: String        // 登場シーン名
    let sceneDescription: String // シーンの説明
    let coordinate: CLLocationCoordinate2D
    let category: Category
    let imageName: String?       // シーン参考画像名

    enum Category: String, CaseIterable, Identifiable {
        case anime = "アニメ"
        case movie = "映画"
        case drama = "ドラマ"
        case game = "ゲーム"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .anime: return "sparkles"
            case .movie: return "film"
            case .drama: return "tv"
            case .game: return "gamecontroller"
            }
        }

        var tintColor: String {
            switch self {
            case .anime: return "purple"
            case .movie: return "red"
            case .drama: return "blue"
            case .game: return "green"
            }
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        workTitle: String,
        sceneName: String,
        sceneDescription: String,
        latitude: Double,
        longitude: Double,
        category: Category,
        imageName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.workTitle = workTitle
        self.sceneName = sceneName
        self.sceneDescription = sceneDescription
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.category = category
        self.imageName = imageName
    }

    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PilgrimageSpot, rhs: PilgrimageSpot) -> Bool {
        lhs.id == rhs.id
    }
}
