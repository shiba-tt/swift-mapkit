import Foundation
import CoreLocation

/// Provides sample environmental data for the Tokyo/Shinjuku area
enum SampleDataProvider {

    // MARK: - Parks

    static let parks: [ParkRegion] = [
        ParkRegion(
            name: "新宿御苑",
            center: CLLocationCoordinate2D(latitude: 35.6852, longitude: 139.7100),
            coordinates: [
                CLLocationCoordinate2D(latitude: 35.6880, longitude: 139.7060),
                CLLocationCoordinate2D(latitude: 35.6880, longitude: 139.7140),
                CLLocationCoordinate2D(latitude: 35.6825, longitude: 139.7145),
                CLLocationCoordinate2D(latitude: 35.6820, longitude: 139.7065)
            ],
            area: 583_000,
            treeCount: 10_000,
            description: "日本庭園、イギリス式庭園、フランス式庭園を有する広大な国民公園"
        ),
        ParkRegion(
            name: "代々木公園",
            center: CLLocationCoordinate2D(latitude: 35.6718, longitude: 139.6950),
            coordinates: [
                CLLocationCoordinate2D(latitude: 35.6755, longitude: 139.6910),
                CLLocationCoordinate2D(latitude: 35.6760, longitude: 139.6990),
                CLLocationCoordinate2D(latitude: 35.6685, longitude: 139.6995),
                CLLocationCoordinate2D(latitude: 35.6680, longitude: 139.6915)
            ],
            area: 540_000,
            treeCount: 3_700,
            description: "都心に残された貴重な森林公園。イベント広場も有名"
        ),
        ParkRegion(
            name: "明治神宮外苑",
            center: CLLocationCoordinate2D(latitude: 35.6745, longitude: 139.7170),
            coordinates: [
                CLLocationCoordinate2D(latitude: 35.6775, longitude: 139.7145),
                CLLocationCoordinate2D(latitude: 35.6778, longitude: 139.7200),
                CLLocationCoordinate2D(latitude: 35.6718, longitude: 139.7198),
                CLLocationCoordinate2D(latitude: 35.6715, longitude: 139.7148)
            ],
            area: 300_000,
            treeCount: 1_500,
            description: "イチョウ並木で有名な文化・スポーツエリア"
        ),
        ParkRegion(
            name: "新宿中央公園",
            center: CLLocationCoordinate2D(latitude: 35.6910, longitude: 139.6905),
            coordinates: [
                CLLocationCoordinate2D(latitude: 35.6930, longitude: 139.6890),
                CLLocationCoordinate2D(latitude: 35.6932, longitude: 139.6920),
                CLLocationCoordinate2D(latitude: 35.6890, longitude: 139.6922),
                CLLocationCoordinate2D(latitude: 35.6888, longitude: 139.6892)
            ],
            area: 88_000,
            treeCount: 500,
            description: "新宿副都心のオアシス。滝や芝生広場が人気"
        ),
        ParkRegion(
            name: "戸山公園",
            center: CLLocationCoordinate2D(latitude: 35.7020, longitude: 139.7160),
            coordinates: [
                CLLocationCoordinate2D(latitude: 35.7040, longitude: 139.7140),
                CLLocationCoordinate2D(latitude: 35.7042, longitude: 139.7180),
                CLLocationCoordinate2D(latitude: 35.7000, longitude: 139.7182),
                CLLocationCoordinate2D(latitude: 35.6998, longitude: 139.7142)
            ],
            area: 186_000,
            treeCount: 800,
            description: "箱根山がある自然豊かな都立公園"
        )
    ]

    // MARK: - Street Trees

    static let streetTrees: [StreetTree] = {
        var trees: [StreetTree] = []

        // 新宿通り沿い（イチョウ並木）
        let shinjukuDoriLat = 35.6895
        for i in 0..<8 {
            trees.append(StreetTree(
                coordinate: CLLocationCoordinate2D(
                    latitude: shinjukuDoriLat + Double.random(in: -0.0003...0.0003),
                    longitude: 139.6980 + Double(i) * 0.0018
                ),
                species: "Ginkgo",
                height: Double.random(in: 10...18),
                trunkDiameter: Double.random(in: 30...60),
                healthStatus: [.excellent, .good, .good].randomElement()!
            ))
        }

        // 明治通り沿い（ケヤキ）
        let meijiDoriLon = 139.7030
        for i in 0..<6 {
            trees.append(StreetTree(
                coordinate: CLLocationCoordinate2D(
                    latitude: 35.6850 + Double(i) * 0.0020,
                    longitude: meijiDoriLon + Double.random(in: -0.0003...0.0003)
                ),
                species: "Zelkova",
                height: Double.random(in: 12...20),
                trunkDiameter: Double.random(in: 40...70),
                healthStatus: [.excellent, .excellent, .good].randomElement()!
            ))
        }

        // 甲州街道沿い（サクラ）
        let koshuLat = 35.6830
        for i in 0..<7 {
            trees.append(StreetTree(
                coordinate: CLLocationCoordinate2D(
                    latitude: koshuLat + Double.random(in: -0.0002...0.0002),
                    longitude: 139.6920 + Double(i) * 0.0022
                ),
                species: "Cherry",
                height: Double.random(in: 6...12),
                trunkDiameter: Double.random(in: 20...45),
                healthStatus: TreeHealthStatus.allCases.randomElement()!
            ))
        }

        // 表参道（ケヤキ並木）
        for i in 0..<5 {
            trees.append(StreetTree(
                coordinate: CLLocationCoordinate2D(
                    latitude: 35.6670 + Double(i) * 0.0015,
                    longitude: 139.7060 + Double(i) * 0.0010
                ),
                species: "Zelkova",
                height: Double.random(in: 15...25),
                trunkDiameter: Double.random(in: 50...80),
                healthStatus: [.excellent, .excellent, .good].randomElement()!
            ))
        }

        // 外苑前イチョウ並木
        for i in 0..<6 {
            trees.append(StreetTree(
                coordinate: CLLocationCoordinate2D(
                    latitude: 35.6730 + Double(i) * 0.0008,
                    longitude: 139.7170 + Double.random(in: -0.0002...0.0002)
                ),
                species: "Ginkgo",
                height: Double.random(in: 15...28),
                trunkDiameter: Double.random(in: 50...90),
                healthStatus: [.excellent, .good].randomElement()!
            ))
        }

        // 散在する街路樹
        let scatteredSpecies = ["Camphor", "Maple", "Pine", "Magnolia", "Dogwood", "Camellia"]
        for _ in 0..<15 {
            trees.append(StreetTree(
                coordinate: CLLocationCoordinate2D(
                    latitude: Double.random(in: 35.665...35.705),
                    longitude: Double.random(in: 139.688...139.722)
                ),
                species: scatteredSpecies.randomElement()!,
                height: Double.random(in: 5...15),
                trunkDiameter: Double.random(in: 15...50),
                healthStatus: TreeHealthStatus.allCases.randomElement()!
            ))
        }

        return trees
    }()

    // MARK: - Environmental Data Points

    static let environmentalData: [EnvironmentalDataPoint] = {
        var points: [EnvironmentalDataPoint] = []

        // Grid of measurement points across the map area
        let latRange = stride(from: 35.665, through: 35.705, by: 0.003)
        let lonRange = stride(from: 35.665, through: 35.705, by: 0.003)

        for lat in latRange {
            for lonStep in stride(from: 139.688, through: 139.722, by: 0.003) {
                let isNearPark = parks.contains { park in
                    let distance = CLLocation(latitude: lat, longitude: lonStep)
                        .distance(from: CLLocation(
                            latitude: park.center.latitude,
                            longitude: park.center.longitude
                        ))
                    return distance < 500
                }

                let isNearMajorRoad = isOnMajorRoad(lat: lat, lon: lonStep)

                // Air quality: better near parks, worse near roads
                var aqi: Double
                if isNearPark {
                    aqi = Double.random(in: 15...50)
                } else if isNearMajorRoad {
                    aqi = Double.random(in: 80...160)
                } else {
                    aqi = Double.random(in: 40...100)
                }

                // Noise: lower near parks, higher near roads
                var noise: Double
                if isNearPark {
                    noise = Double.random(in: 30...50)
                } else if isNearMajorRoad {
                    noise = Double.random(in: 65...85)
                } else {
                    noise = Double.random(in: 45...65)
                }

                // Add some randomness for station/train line noise
                let isNearStation = abs(lat - 35.6896) < 0.003 && abs(lonStep - 139.7006) < 0.005
                if isNearStation {
                    noise += Double.random(in: 5...15)
                    aqi += Double.random(in: 10...30)
                }

                points.append(EnvironmentalDataPoint(
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lonStep),
                    airQualityIndex: min(aqi, 300),
                    noiseLevel: min(noise, 100)
                ))
            }
        }

        return points
    }()

    // MARK: - Helpers

    private static func isOnMajorRoad(lat: Double, lon: Double) -> Bool {
        // Shinjuku-dori (east-west around 35.6895)
        if abs(lat - 35.6895) < 0.002 && lon > 139.695 && lon < 139.720 {
            return true
        }
        // Meiji-dori (north-south around 139.703)
        if abs(lon - 139.7030) < 0.002 && lat > 35.680 && lat < 35.700 {
            return true
        }
        // Koshu-kaido (east-west around 35.683)
        if abs(lat - 35.6830) < 0.002 && lon > 139.690 && lon < 139.715 {
            return true
        }
        // Yamate-dori (north-south around 139.693)
        if abs(lon - 139.6930) < 0.002 && lat > 35.670 && lat < 35.705 {
            return true
        }
        return false
    }
}
