import Foundation
import CoreLocation

// MARK: - サンプルデータ
struct SampleData {

    // MARK: - 日付ヘルパー
    private static func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    // MARK: - 犯罪発生情報サンプル
    static let crimeIncidents: [CrimeIncident] = [
        // 新宿エリア
        CrimeIncident(
            type: .theft,
            title: "置き引き",
            description: "新宿駅東口付近のカフェで置き引き被害が発生。バッグを椅子にかけたまま離席した際に盗まれた。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6896, longitude: 139.7006),
            date: date(daysAgo: 2),
            severity: .medium
        ),
        CrimeIncident(
            type: .fraud,
            title: "キャッチセールス詐欺",
            description: "歌舞伎町エリアでキャッチセールスによる高額契約の被害が報告。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6938, longitude: 139.7034),
            date: date(daysAgo: 5),
            severity: .medium
        ),
        CrimeIncident(
            type: .suspiciousPerson,
            title: "不審者目撃情報",
            description: "新宿御苑付近で深夜に不審な行動をする人物が複数回目撃されている。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6852, longitude: 139.7100),
            date: date(daysAgo: 1),
            severity: .low
        ),

        // 渋谷エリア
        CrimeIncident(
            type: .theft,
            title: "スリ被害",
            description: "渋谷スクランブル交差点付近で混雑時にスリ被害が連続発生。財布やスマートフォンが狙われている。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6595, longitude: 139.7004),
            date: date(daysAgo: 3),
            severity: .high
        ),
        CrimeIncident(
            type: .molester,
            title: "痴漢被害",
            description: "渋谷駅ハチ公口付近の混雑した通路で痴漢被害が報告。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016),
            date: date(daysAgo: 7),
            severity: .high
        ),
        CrimeIncident(
            type: .vandalism,
            title: "落書き・器物損壊",
            description: "道玄坂エリアの建物壁面への落書きと、駐輪場での自転車破損が発生。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6565, longitude: 139.6966),
            date: date(daysAgo: 10),
            severity: .low,
            isResolved: true
        ),

        // 池袋エリア
        CrimeIncident(
            type: .robbery,
            title: "ひったくり",
            description: "池袋駅北口付近でバイクによるひったくり事件が発生。歩行中の女性が被害。",
            coordinate: CLLocationCoordinate2D(latitude: 35.7325, longitude: 139.7106),
            date: date(daysAgo: 4),
            severity: .critical
        ),
        CrimeIncident(
            type: .assault,
            title: "暴行事件",
            description: "池袋西口公園付近で口論から暴行事件に発展。",
            coordinate: CLLocationCoordinate2D(latitude: 35.7295, longitude: 139.7089),
            date: date(daysAgo: 6),
            severity: .high
        ),

        // 上野エリア
        CrimeIncident(
            type: .theft,
            title: "自転車盗難",
            description: "上野駅周辺の駐輪場で施錠された自転車の盗難が複数件発生。",
            coordinate: CLLocationCoordinate2D(latitude: 35.7141, longitude: 139.7774),
            date: date(daysAgo: 8),
            severity: .medium
        ),
        CrimeIncident(
            type: .suspiciousPerson,
            title: "つきまとい",
            description: "上野公園内で女性へのつきまとい行為が報告されている。",
            coordinate: CLLocationCoordinate2D(latitude: 35.7146, longitude: 139.7714),
            date: date(daysAgo: 3),
            severity: .medium
        ),

        // 六本木エリア
        CrimeIncident(
            type: .fraud,
            title: "ぼったくり被害",
            description: "六本木交差点付近の飲食店で不当な高額請求の被害が複数報告。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6627, longitude: 139.7313),
            date: date(daysAgo: 2),
            severity: .high
        ),
        CrimeIncident(
            type: .assault,
            title: "傷害事件",
            description: "六本木通り沿いの路上で深夜に傷害事件が発生。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6605, longitude: 139.7292),
            date: date(daysAgo: 9),
            severity: .critical,
            isResolved: true
        ),

        // 秋葉原エリア
        CrimeIncident(
            type: .stalking,
            title: "ストーカー被害",
            description: "秋葉原駅周辺で特定人物による執拗なつきまとい被害が報告。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6984, longitude: 139.7731),
            date: date(daysAgo: 5),
            severity: .high
        ),
        CrimeIncident(
            type: .theft,
            title: "万引き多発",
            description: "電気街の複数店舗で組織的な万引き被害が報告されている。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6994, longitude: 139.7711),
            date: date(daysAgo: 12),
            severity: .medium
        ),

        // 品川エリア
        CrimeIncident(
            type: .molester,
            title: "痴漢被害（電車内）",
            description: "品川駅発の混雑した通勤電車内での痴漢被害が報告。",
            coordinate: CLLocationCoordinate2D(latitude: 35.6284, longitude: 139.7387),
            date: date(daysAgo: 1),
            severity: .high
        ),
    ]

    // MARK: - 防犯カメラサンプル
    static let securityCameras: [SecurityCamera] = [
        // 新宿エリア
        SecurityCamera(
            type: .police,
            name: "新宿駅東口交番前",
            coordinate: CLLocationCoordinate2D(latitude: 35.6897, longitude: 139.7013),
            installedDate: date(daysAgo: 365)
        ),
        SecurityCamera(
            type: .municipal,
            name: "歌舞伎町一番街入口",
            coordinate: CLLocationCoordinate2D(latitude: 35.6942, longitude: 139.7030),
            installedDate: date(daysAgo: 200)
        ),
        SecurityCamera(
            type: .municipal,
            name: "歌舞伎町シネシティ広場",
            coordinate: CLLocationCoordinate2D(latitude: 35.6950, longitude: 139.7020),
            installedDate: date(daysAgo: 180)
        ),
        SecurityCamera(
            type: .commercial,
            name: "新宿アルタ前",
            coordinate: CLLocationCoordinate2D(latitude: 35.6927, longitude: 139.7012),
            installedDate: date(daysAgo: 500)
        ),
        SecurityCamera(
            type: .traffic,
            name: "新宿大ガード交差点",
            coordinate: CLLocationCoordinate2D(latitude: 35.6920, longitude: 139.6982),
            installedDate: date(daysAgo: 730)
        ),

        // 渋谷エリア
        SecurityCamera(
            type: .municipal,
            name: "渋谷スクランブル交差点",
            coordinate: CLLocationCoordinate2D(latitude: 35.6594, longitude: 139.7005),
            installedDate: date(daysAgo: 300)
        ),
        SecurityCamera(
            type: .police,
            name: "渋谷駅前交番",
            coordinate: CLLocationCoordinate2D(latitude: 35.6590, longitude: 139.7020),
            installedDate: date(daysAgo: 400)
        ),
        SecurityCamera(
            type: .commercial,
            name: "渋谷109前",
            coordinate: CLLocationCoordinate2D(latitude: 35.6590, longitude: 139.6985),
            installedDate: date(daysAgo: 250)
        ),
        SecurityCamera(
            type: .traffic,
            name: "道玄坂交差点",
            coordinate: CLLocationCoordinate2D(latitude: 35.6567, longitude: 139.6970),
            installedDate: date(daysAgo: 600)
        ),

        // 池袋エリア
        SecurityCamera(
            type: .police,
            name: "池袋駅北口交番",
            coordinate: CLLocationCoordinate2D(latitude: 35.7330, longitude: 139.7110),
            installedDate: date(daysAgo: 350)
        ),
        SecurityCamera(
            type: .municipal,
            name: "池袋西口公園",
            coordinate: CLLocationCoordinate2D(latitude: 35.7293, longitude: 139.7085),
            installedDate: date(daysAgo: 150)
        ),
        SecurityCamera(
            type: .commercial,
            name: "サンシャイン60通り",
            coordinate: CLLocationCoordinate2D(latitude: 35.7290, longitude: 139.7170),
            installedDate: date(daysAgo: 280)
        ),

        // 上野エリア
        SecurityCamera(
            type: .municipal,
            name: "上野駅不忍口",
            coordinate: CLLocationCoordinate2D(latitude: 35.7138, longitude: 139.7770),
            installedDate: date(daysAgo: 400)
        ),
        SecurityCamera(
            type: .municipal,
            name: "上野公園入口",
            coordinate: CLLocationCoordinate2D(latitude: 35.7150, longitude: 139.7720),
            installedDate: date(daysAgo: 250),
            isActive: false
        ),
        SecurityCamera(
            type: .commercial,
            name: "アメ横入口",
            coordinate: CLLocationCoordinate2D(latitude: 35.7105, longitude: 139.7745),
            installedDate: date(daysAgo: 500)
        ),

        // 六本木エリア
        SecurityCamera(
            type: .police,
            name: "六本木交番",
            coordinate: CLLocationCoordinate2D(latitude: 35.6630, longitude: 139.7315),
            installedDate: date(daysAgo: 300)
        ),
        SecurityCamera(
            type: .commercial,
            name: "六本木ヒルズ前",
            coordinate: CLLocationCoordinate2D(latitude: 35.6602, longitude: 139.7293),
            installedDate: date(daysAgo: 700)
        ),

        // 秋葉原エリア
        SecurityCamera(
            type: .municipal,
            name: "秋葉原駅電気街口",
            coordinate: CLLocationCoordinate2D(latitude: 35.6988, longitude: 139.7730),
            installedDate: date(daysAgo: 200)
        ),
        SecurityCamera(
            type: .commercial,
            name: "中央通り（秋葉原）",
            coordinate: CLLocationCoordinate2D(latitude: 35.6998, longitude: 139.7715),
            installedDate: date(daysAgo: 350)
        ),

        // 品川エリア
        SecurityCamera(
            type: .traffic,
            name: "品川駅港南口",
            coordinate: CLLocationCoordinate2D(latitude: 35.6288, longitude: 139.7400),
            installedDate: date(daysAgo: 450)
        ),
        SecurityCamera(
            type: .residential,
            name: "品川シーサイドレジデンス",
            coordinate: CLLocationCoordinate2D(latitude: 35.6250, longitude: 139.7420),
            installedDate: date(daysAgo: 300)
        ),
    ]

    // MARK: - 危険エリアサンプル
    static let dangerZones: [DangerZone] = [
        DangerZone(
            name: "歌舞伎町",
            center: CLLocationCoordinate2D(latitude: 35.6940, longitude: 139.7030),
            radius: 350,
            level: .danger,
            crimeCount: 45,
            description: "深夜の客引き、ぼったくり、暴行事件が多発するエリア。特に深夜帯は注意が必要。"
        ),
        DangerZone(
            name: "渋谷センター街",
            center: CLLocationCoordinate2D(latitude: 35.6598, longitude: 139.6990),
            radius: 250,
            level: .warning,
            crimeCount: 28,
            description: "スリ・置き引きが多発。混雑時は特に注意。"
        ),
        DangerZone(
            name: "池袋北口",
            center: CLLocationCoordinate2D(latitude: 35.7325, longitude: 139.7105),
            radius: 300,
            level: .danger,
            crimeCount: 38,
            description: "ひったくり・暴行事件が集中するエリア。深夜の一人歩きは避けること。"
        ),
        DangerZone(
            name: "六本木",
            center: CLLocationCoordinate2D(latitude: 35.6620, longitude: 139.7305),
            radius: 280,
            level: .warning,
            crimeCount: 22,
            description: "深夜のぼったくり・詐欺被害が報告されているエリア。"
        ),
        DangerZone(
            name: "上野アメ横",
            center: CLLocationCoordinate2D(latitude: 35.7105, longitude: 139.7745),
            radius: 200,
            level: .caution,
            crimeCount: 12,
            description: "スリ・万引きの報告があるエリア。混雑時の貴重品管理に注意。"
        ),
        DangerZone(
            name: "品川駅周辺",
            center: CLLocationCoordinate2D(latitude: 35.6284, longitude: 139.7390),
            radius: 200,
            level: .caution,
            crimeCount: 8,
            description: "通勤時間帯の痴漢被害が報告されているエリア。"
        ),
        DangerZone(
            name: "新宿南口",
            center: CLLocationCoordinate2D(latitude: 35.6870, longitude: 139.6990),
            radius: 220,
            level: .caution,
            crimeCount: 15,
            description: "置き引き・スリ被害が報告されているエリア。"
        ),
        DangerZone(
            name: "秋葉原電気街",
            center: CLLocationCoordinate2D(latitude: 35.6990, longitude: 139.7720),
            radius: 200,
            level: .caution,
            crimeCount: 10,
            description: "万引き・ストーカー被害が報告されているエリア。"
        ),
    ]
}
