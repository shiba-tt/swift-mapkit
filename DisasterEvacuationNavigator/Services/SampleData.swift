import Foundation
import CoreLocation

/// サンプルデータ（東京都周辺）
enum SampleData {

    // MARK: - 避難所サンプルデータ

    static let shelters: [EvacuationShelter] = [
        EvacuationShelter(
            name: "新宿区立新宿中学校",
            address: "東京都新宿区新宿6-8-1",
            coordinate: CLLocationCoordinate2D(latitude: 35.6938, longitude: 139.7050),
            shelterTypes: [.earthquake, .general],
            capacity: 500,
            phoneNumber: "03-3202-1241",
            note: "体育館・教室を開放"
        ),
        EvacuationShelter(
            name: "渋谷区立神南小学校",
            address: "東京都渋谷区神南2-1",
            coordinate: CLLocationCoordinate2D(latitude: 35.6645, longitude: 139.6990),
            shelterTypes: [.earthquake, .fire, .general],
            capacity: 300
        ),
        EvacuationShelter(
            name: "港区立芝公園多目的広場",
            address: "東京都港区芝公園4-8-4",
            coordinate: CLLocationCoordinate2D(latitude: 35.6544, longitude: 139.7480),
            shelterTypes: [.earthquake, .fire],
            capacity: 1000,
            note: "広域避難場所"
        ),
        EvacuationShelter(
            name: "千代田区立お茶の水小学校",
            address: "東京都千代田区神田駿河台2-8",
            coordinate: CLLocationCoordinate2D(latitude: 35.6990, longitude: 139.7640),
            shelterTypes: [.earthquake, .flood, .general],
            capacity: 400,
            phoneNumber: "03-3291-3251"
        ),
        EvacuationShelter(
            name: "江東区立有明西学園",
            address: "東京都江東区有明2-16-1",
            coordinate: CLLocationCoordinate2D(latitude: 35.6380, longitude: 139.7890),
            shelterTypes: [.flood, .tsunami, .general],
            capacity: 800,
            note: "津波避難ビル指定"
        ),
        EvacuationShelter(
            name: "墨田区立錦糸公園",
            address: "東京都墨田区錦糸4-15-1",
            coordinate: CLLocationCoordinate2D(latitude: 35.6960, longitude: 139.8140),
            shelterTypes: [.earthquake, .flood],
            capacity: 2000,
            note: "広域避難場所・荒川氾濫時は使用不可"
        ),
        EvacuationShelter(
            name: "品川区立大井第一小学校",
            address: "東京都品川区大井6-1-32",
            coordinate: CLLocationCoordinate2D(latitude: 35.6050, longitude: 139.7350),
            shelterTypes: [.earthquake, .general],
            capacity: 350,
            phoneNumber: "03-3771-5765"
        ),
        EvacuationShelter(
            name: "世田谷区立駒沢オリンピック公園",
            address: "東京都世田谷区駒沢公園1-1",
            coordinate: CLLocationCoordinate2D(latitude: 35.6266, longitude: 139.6619),
            shelterTypes: [.earthquake, .fire, .general],
            capacity: 5000,
            note: "広域避難場所"
        ),
        EvacuationShelter(
            name: "台東区立上野公園",
            address: "東京都台東区上野公園5-20",
            coordinate: CLLocationCoordinate2D(latitude: 35.7146, longitude: 139.7714),
            shelterTypes: [.earthquake, .general],
            capacity: 3000,
            note: "広域避難場所"
        ),
        EvacuationShelter(
            name: "足立区立足立入谷小学校",
            address: "東京都足立区入谷9-22-1",
            coordinate: CLLocationCoordinate2D(latitude: 35.7880, longitude: 139.8050),
            shelterTypes: [.flood, .general],
            capacity: 250,
            isOpen: false,
            note: "現在改修工事中"
        ),
        EvacuationShelter(
            name: "葛飾区立水元公園",
            address: "東京都葛飾区水元公園3-2",
            coordinate: CLLocationCoordinate2D(latitude: 35.7870, longitude: 139.8670),
            shelterTypes: [.earthquake, .general],
            capacity: 4000,
            note: "広域避難場所・浸水時は利用不可"
        ),
        EvacuationShelter(
            name: "中央区立浜町公園",
            address: "東京都中央区日本橋浜町2-59-1",
            coordinate: CLLocationCoordinate2D(latitude: 35.6880, longitude: 139.7870),
            shelterTypes: [.earthquake, .flood, .general],
            capacity: 600
        )
    ]

    // MARK: - 浸水想定区域サンプルデータ

    static let floodZones: [FloodZone] = [
        // 荒川流域
        FloodZone(
            name: "荒川下流域 足立区付近",
            center: CLLocationCoordinate2D(latitude: 35.7750, longitude: 139.8000),
            radius: 1200,
            depthLevel: .veryDeep,
            riverName: "荒川",
            description: "荒川が氾濫した場合、最大浸水深5m程度"
        ),
        FloodZone(
            name: "荒川下流域 墨田区付近",
            center: CLLocationCoordinate2D(latitude: 35.7100, longitude: 139.8200),
            radius: 900,
            depthLevel: .deep,
            riverName: "荒川",
            description: "荒川氾濫時、浸水深1〜2m程度"
        ),
        FloodZone(
            name: "荒川下流域 江東区北部",
            center: CLLocationCoordinate2D(latitude: 35.6700, longitude: 139.8200),
            radius: 1500,
            depthLevel: .extreme,
            riverName: "荒川",
            description: "海抜ゼロメートル地帯。最大浸水深5m以上"
        ),
        FloodZone(
            name: "葛飾区 中川流域",
            center: CLLocationCoordinate2D(latitude: 35.7600, longitude: 139.8600),
            radius: 800,
            depthLevel: .deep,
            riverName: "中川",
            description: "中川氾濫時の浸水想定区域"
        ),

        // 神田川流域
        FloodZone(
            name: "神田川流域 新宿区付近",
            center: CLLocationCoordinate2D(latitude: 35.7050, longitude: 139.7150),
            radius: 400,
            depthLevel: .shallow,
            riverName: "神田川",
            description: "集中豪雨時の内水氾濫想定区域"
        ),
        FloodZone(
            name: "神田川流域 文京区付近",
            center: CLLocationCoordinate2D(latitude: 35.7080, longitude: 139.7500),
            radius: 500,
            depthLevel: .moderate,
            riverName: "神田川",
            description: "神田川氾濫時の浸水想定区域"
        ),

        // 目黒川流域
        FloodZone(
            name: "目黒川流域 品川区付近",
            center: CLLocationCoordinate2D(latitude: 35.6200, longitude: 139.7300),
            radius: 350,
            depthLevel: .shallow,
            riverName: "目黒川",
            description: "目黒川の内水氾濫想定区域"
        ),

        // 多摩川流域
        FloodZone(
            name: "多摩川流域 世田谷区付近",
            center: CLLocationCoordinate2D(latitude: 35.6100, longitude: 139.6500),
            radius: 700,
            depthLevel: .moderate,
            riverName: "多摩川",
            description: "多摩川氾濫時の浸水想定区域"
        ),

        // 隅田川流域
        FloodZone(
            name: "隅田川流域 中央区付近",
            center: CLLocationCoordinate2D(latitude: 35.6850, longitude: 139.7900),
            radius: 600,
            depthLevel: .moderate,
            riverName: "隅田川",
            description: "高潮・隅田川氾濫時の想定区域"
        ),

        // 江戸川流域
        FloodZone(
            name: "江戸川流域 葛飾区付近",
            center: CLLocationCoordinate2D(latitude: 35.7500, longitude: 139.8800),
            radius: 1000,
            depthLevel: .veryDeep,
            riverName: "江戸川",
            description: "江戸川氾濫時の浸水想定区域"
        )
    ]
}
