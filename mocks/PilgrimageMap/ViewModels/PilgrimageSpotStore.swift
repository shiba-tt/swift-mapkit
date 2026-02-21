import Foundation
import SwiftUI

/// 聖地巡礼スポットとチェックインを管理するストア
@Observable
final class PilgrimageSpotStore {
    var spots: [PilgrimageSpot] = []
    var checkIns: [CheckIn] = []
    var selectedCategory: PilgrimageSpot.Category?

    private let checkInsKey = "savedCheckIns"

    var filteredSpots: [PilgrimageSpot] {
        guard let category = selectedCategory else { return spots }
        return spots.filter { $0.category == category }
    }

    init() {
        loadSampleSpots()
        loadCheckIns()
    }

    // MARK: - Check-In

    func checkIn(spot: PilgrimageSpot, note: String = "") {
        let checkIn = CheckIn(
            spotID: spot.id,
            spotName: spot.name,
            workTitle: spot.workTitle,
            note: note
        )
        checkIns.insert(checkIn, at: 0)
        saveCheckIns()
    }

    func hasCheckedIn(spot: PilgrimageSpot) -> Bool {
        checkIns.contains { $0.spotID == spot.id }
    }

    func checkInCount(for spot: PilgrimageSpot) -> Int {
        checkIns.filter { $0.spotID == spot.id }.count
    }

    func deleteCheckIn(at offsets: IndexSet) {
        checkIns.remove(atOffsets: offsets)
        saveCheckIns()
    }

    // MARK: - Persistence

    private func saveCheckIns() {
        if let data = try? JSONEncoder().encode(checkIns) {
            UserDefaults.standard.set(data, forKey: checkInsKey)
        }
    }

    private func loadCheckIns() {
        guard let data = UserDefaults.standard.data(forKey: checkInsKey),
              let saved = try? JSONDecoder().decode([CheckIn].self, from: data) else {
            return
        }
        checkIns = saved
    }

    // MARK: - Sample Data

    private func loadSampleSpots() {
        spots = [
            // 君の名は。
            PilgrimageSpot(
                name: "須賀神社",
                workTitle: "君の名は。",
                sceneName: "ラストシーンの階段",
                sceneDescription: "瀧と三葉が再会する感動的なラストシーンの舞台となった階段。四谷の須賀神社前の石段は、映画を象徴する場所として多くのファンが訪れます。",
                latitude: 35.6873,
                longitude: 139.7194,
                category: .anime
            ),
            PilgrimageSpot(
                name: "飛騨古川駅",
                workTitle: "君の名は。",
                sceneName: "糸守町のモデル駅",
                sceneDescription: "瀧が三葉を探して訪れた駅のモデル。飛騨地方の美しい景色とともに、作品の世界観を体感できます。",
                latitude: 36.2381,
                longitude: 137.1861,
                category: .anime
            ),

            // スラムダンク
            PilgrimageSpot(
                name: "鎌倉高校前踏切",
                workTitle: "SLAM DUNK",
                sceneName: "オープニングの踏切",
                sceneDescription: "スラムダンクのオープニングで桜木花道が電車を見送る有名な踏切。江ノ島をバックにした景色は、海外からも多くのファンが訪れる人気スポットです。",
                latitude: 35.3067,
                longitude: 139.4955,
                category: .anime
            ),

            // エヴァンゲリオン
            PilgrimageSpot(
                name: "箱根湯本駅",
                workTitle: "エヴァンゲリオン",
                sceneName: "第3新東京市の最寄り駅",
                sceneDescription: "第3新東京市のモデルとなった箱根。駅周辺にはエヴァンゲリオン関連の展示やコラボ施設があり、聖地巡礼の拠点として最適です。",
                latitude: 35.2326,
                longitude: 139.1060,
                category: .anime
            ),

            // ラブライブ！
            PilgrimageSpot(
                name: "神田明神",
                workTitle: "ラブライブ！",
                sceneName: "μ'sの活動拠点",
                sceneDescription: "穂乃果たちが参拝していた神社のモデル。ラブライブ！関連の絵馬も多数奉納されており、ファンの聖地として親しまれています。",
                latitude: 35.7020,
                longitude: 139.7681,
                category: .anime
            ),

            // 万引き家族
            PilgrimageSpot(
                name: "荒川区東尾久周辺",
                workTitle: "万引き家族",
                sceneName: "柴田家の生活圏",
                sceneDescription: "是枝裕和監督のパルムドール受賞作。下町の雰囲気が色濃く残る東尾久周辺は、作品の生活感あふれる世界観を体感できます。",
                latitude: 35.7510,
                longitude: 139.7660,
                category: .movie
            ),

            // 海街diary
            PilgrimageSpot(
                name: "極楽寺駅",
                workTitle: "海街diary",
                sceneName: "四姉妹の最寄り駅",
                sceneDescription: "鎌倉を舞台にした是枝裕和監督作品。極楽寺駅は四姉妹の暮らすエリアの最寄り駅として、作品の温かい雰囲気を感じられます。",
                latitude: 35.3104,
                longitude: 139.5300,
                category: .movie
            ),

            // 東京ラブストーリー
            PilgrimageSpot(
                name: "梅津寺駅",
                workTitle: "東京ラブストーリー",
                sceneName: "最終回のハンカチシーン",
                sceneDescription: "リカがカンチへの想いを込めたハンカチを柵に結ぶ名シーン。愛媛県の小さな駅が、日本のドラマ史に残る聖地となりました。",
                latitude: 33.8553,
                longitude: 132.7078,
                category: .drama
            ),

            // 孤独のグルメ
            PilgrimageSpot(
                name: "赤羽駅周辺",
                workTitle: "孤独のグルメ",
                sceneName: "五郎が訪れた飲食街",
                sceneDescription: "井之頭五郎が一人で食事を楽しむ姿が印象的なドラマ。赤羽の下町の飲食街は、作品に登場する名店が多数あります。",
                latitude: 35.7782,
                longitude: 139.7209,
                category: .drama
            ),

            // ペルソナ5
            PilgrimageSpot(
                name: "渋谷駅前スクランブル交差点",
                workTitle: "ペルソナ5",
                sceneName: "渋谷の街並み",
                sceneDescription: "怪盗団の活動拠点・渋谷。ゲーム内で忠実に再現されたスクランブル交差点は、ペルソナ5の世界への入口です。",
                latitude: 35.6595,
                longitude: 139.7004,
                category: .game
            ),

            // 龍が如く
            PilgrimageSpot(
                name: "歌舞伎町一番街",
                workTitle: "龍が如く",
                sceneName: "神室町のモデル",
                sceneDescription: "神室町のモデルとなった歌舞伎町。ゲームに登場する街並みをそのまま体験でき、シリーズファンには聖地です。",
                latitude: 35.6938,
                longitude: 139.7034,
                category: .game
            ),

            // 花束みたいな恋をした
            PilgrimageSpot(
                name: "京王多摩川駅",
                workTitle: "花束みたいな恋をした",
                sceneName: "麦と絹の生活圏",
                sceneDescription: "麦と絹が暮らした街。多摩川沿いの穏やかな風景は、二人の日常を彩った場所として、作品ファンに人気のスポットです。",
                latitude: 35.6498,
                longitude: 139.4428,
                category: .movie
            ),
        ]
    }
}
