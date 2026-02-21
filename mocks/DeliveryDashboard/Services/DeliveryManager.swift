import Foundation
import CoreLocation
import Combine

/// リアルタイム配達管理を行うマネージャー。
/// シミュレーションによりドライバーの位置を更新し、配達の進捗を管理する。
@MainActor
final class DeliveryManager: ObservableObject {
    @Published var drivers: [Driver] = []
    @Published var deliveries: [Delivery] = []
    @Published var routes: [DeliveryRoute] = []
    @Published var stats: DashboardStats = DashboardStats(
        totalDeliveries: 0,
        completedDeliveries: 0,
        activeDrivers: 0,
        idleDrivers: 0,
        averageDeliveryTime: 0,
        onTimeRate: 0
    )
    @Published var selectedDriverID: UUID?
    @Published var selectedDeliveryID: UUID?

    private var simulationTimer: Timer?
    private var tickCount: Int = 0

    // 東京駅周辺を中心とした配達エリア
    static let centerCoordinate = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
    static let regionSpan: Double = 0.05

    init() {
        setupInitialData()
        startSimulation()
    }

    deinit {
        simulationTimer?.invalidate()
    }

    // MARK: - Initial Data Setup

    private func setupInitialData() {
        // ドライバー生成（東京駅周辺）
        let driverData: [(String, Double, Double, Driver.DriverStatus, Driver.VehicleType)] = [
            ("田中 太郎", 35.6835, 139.7710, .enRoute, .car),
            ("佐藤 花子", 35.6790, 139.7630, .enRoute, .bike),
            ("鈴木 一郎", 35.6850, 139.7580, .idle, .car),
            ("高橋 美咲", 35.6770, 139.7720, .delivering, .bicycle),
            ("伊藤 健太", 35.6810, 139.7650, .enRoute, .car),
            ("渡辺 さくら", 35.6860, 139.7690, .returning, .bike),
            ("山本 大輔", 35.6780, 139.7600, .idle, .car),
            ("中村 由美", 35.6840, 139.7750, .enRoute, .bicycle),
        ]

        drivers = driverData.map { name, lat, lng, status, vehicle in
            Driver(
                id: UUID(),
                name: name,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                heading: Double.random(in: 0..<360),
                status: status,
                vehicleType: vehicle,
                currentDeliveryID: nil,
                completedCount: Int.random(in: 3...15)
            )
        }

        // 配達データ生成
        let deliveryAddresses: [(String, Double, Double, String, Double, Double)] = [
            ("丸の内ビル", 35.6823, 139.7637, "日本橋三越", 35.6860, 139.7740),
            ("東京ミッドタウン", 35.6654, 139.7310, "六本木ヒルズ", 35.6605, 139.7292),
            ("銀座松屋", 35.6717, 139.7657, "有楽町マリオン", 35.6743, 139.7630),
            ("秋葉原UDX", 35.7006, 139.7726, "上野松坂屋", 35.7087, 139.7740),
            ("新宿高島屋", 35.6870, 139.7024, "渋谷ヒカリエ", 35.6590, 139.7038),
            ("品川インターシティ", 35.6189, 139.7408, "大崎ゲートシティ", 35.6195, 139.7280),
        ]

        deliveries = deliveryAddresses.enumerated().map { index, data in
            let (pickAddr, pickLat, pickLng, dropAddr, dropLat, dropLng) = data
            let status: Delivery.DeliveryStatus = switch index {
            case 0, 1: .inTransit
            case 2: .pickedUp
            case 3: .assigned
            case 4: .pending
            default: .delivered
            }
            return Delivery(
                id: UUID(),
                orderNumber: "ORD-\(2024000 + index)",
                pickupLocation: CLLocationCoordinate2D(latitude: pickLat, longitude: pickLng),
                pickupAddress: pickAddr,
                dropoffLocation: CLLocationCoordinate2D(latitude: dropLat, longitude: dropLng),
                dropoffAddress: dropAddr,
                status: status,
                assignedDriverID: index < drivers.count ? drivers[index].id : nil,
                estimatedArrival: Date().addingTimeInterval(Double.random(in: 300...1800)),
                createdAt: Date().addingTimeInterval(-Double.random(in: 600...3600))
            )
        }

        // 配達中ドライバーに配達IDを割り当て
        for i in 0..<min(drivers.count, deliveries.count) {
            if drivers[i].status == .enRoute || drivers[i].status == .delivering {
                drivers[i].currentDeliveryID = deliveries[i].id
            }
        }

        // ルート生成
        generateRoutes()
        updateStats()
    }

    // MARK: - Route Generation

    private func generateRoutes() {
        routes = []

        for driver in drivers where driver.status == .enRoute || driver.status == .delivering {
            guard let deliveryID = driver.currentDeliveryID,
                  let delivery = deliveries.first(where: { $0.id == deliveryID }) else {
                continue
            }

            let waypoints = [
                DeliveryRoute.Waypoint(
                    id: UUID(),
                    coordinate: driver.coordinate,
                    label: "現在地",
                    type: .warehouse,
                    order: 0
                ),
                DeliveryRoute.Waypoint(
                    id: UUID(),
                    coordinate: delivery.pickupLocation,
                    label: delivery.pickupAddress,
                    type: .pickup,
                    order: 1
                ),
                DeliveryRoute.Waypoint(
                    id: UUID(),
                    coordinate: delivery.dropoffLocation,
                    label: delivery.dropoffAddress,
                    type: .dropoff,
                    order: 2
                ),
            ]

            let polyline = generatePolyline(
                from: driver.coordinate,
                through: delivery.pickupLocation,
                to: delivery.dropoffLocation
            )

            let route = DeliveryRoute(
                id: UUID(),
                driverID: driver.id,
                waypoints: waypoints,
                polylineCoordinates: polyline,
                totalDistance: calculateDistance(polyline),
                estimatedDuration: Double.random(in: 600...1800),
                isOptimized: Bool.random()
            )
            routes.append(route)
        }
    }

    private func generatePolyline(
        from start: CLLocationCoordinate2D,
        through mid: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        let segments = 8

        // start -> mid
        for i in 0...segments {
            let t = Double(i) / Double(segments)
            let lat = start.latitude + (mid.latitude - start.latitude) * t
                + Double.random(in: -0.001...0.001)
            let lng = start.longitude + (mid.longitude - start.longitude) * t
                + Double.random(in: -0.001...0.001)
            coords.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
        }

        // mid -> end
        for i in 1...segments {
            let t = Double(i) / Double(segments)
            let lat = mid.latitude + (end.latitude - mid.latitude) * t
                + Double.random(in: -0.001...0.001)
            let lng = mid.longitude + (end.longitude - mid.longitude) * t
                + Double.random(in: -0.001...0.001)
            coords.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
        }

        return coords
    }

    private func calculateDistance(_ coordinates: [CLLocationCoordinate2D]) -> CLLocationDistance {
        var total: CLLocationDistance = 0
        for i in 0..<coordinates.count - 1 {
            let from = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
            let to = CLLocation(latitude: coordinates[i + 1].latitude, longitude: coordinates[i + 1].longitude)
            total += from.distance(from: to)
        }
        return total
    }

    // MARK: - Simulation

    private func startSimulation() {
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        tickCount += 1
        updateDriverPositions()

        // 定期的にステータス変更
        if tickCount % 5 == 0 {
            simulateStatusChanges()
        }

        updateStats()
    }

    private func updateDriverPositions() {
        for i in 0..<drivers.count {
            guard drivers[i].status == .enRoute || drivers[i].status == .returning else { continue }

            let speed = switch drivers[i].vehicleType {
            case .car: 0.0008
            case .bike: 0.0005
            case .bicycle: 0.0003
            }

            let headingRad = drivers[i].heading * .pi / 180
            var newLat = drivers[i].coordinate.latitude + speed * cos(headingRad)
            var newLng = drivers[i].coordinate.longitude + speed * sin(headingRad)

            // エリア内に収める
            let center = Self.centerCoordinate
            let span = Self.regionSpan
            if abs(newLat - center.latitude) > span || abs(newLng - center.longitude) > span {
                drivers[i].heading = Double.random(in: 0..<360)
                newLat = drivers[i].coordinate.latitude
                newLng = drivers[i].coordinate.longitude
            }

            // ランダムに方向を微調整
            drivers[i].heading += Double.random(in: -15...15)
            drivers[i].coordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLng)
        }
    }

    private func simulateStatusChanges() {
        let index = Int.random(in: 0..<drivers.count)

        switch drivers[index].status {
        case .idle:
            // 待機中 → 配達開始
            if let pendingDelivery = deliveries.first(where: { $0.status == .pending }) {
                drivers[index].status = .enRoute
                drivers[index].currentDeliveryID = pendingDelivery.id
                if let di = deliveries.firstIndex(where: { $0.id == pendingDelivery.id }) {
                    deliveries[di].status = .inTransit
                    deliveries[di].assignedDriverID = drivers[index].id
                }
            }
        case .enRoute:
            // 配達中 → 配達先到着
            drivers[index].status = .delivering
        case .delivering:
            // 配達先到着 → 帰還中
            drivers[index].status = .returning
            drivers[index].completedCount += 1
            if let deliveryID = drivers[index].currentDeliveryID,
               let di = deliveries.firstIndex(where: { $0.id == deliveryID }) {
                deliveries[di].status = .delivered
            }
            drivers[index].currentDeliveryID = nil
        case .returning:
            // 帰還中 → 待機中
            drivers[index].status = .idle
        }

        generateRoutes()
    }

    // MARK: - Stats

    private func updateStats() {
        let completed = deliveries.filter { $0.status == .delivered }.count
        let active = drivers.filter { $0.status != .idle }.count

        stats = DashboardStats(
            totalDeliveries: deliveries.count,
            completedDeliveries: completed,
            activeDrivers: active,
            idleDrivers: drivers.count - active,
            averageDeliveryTime: 1260,
            onTimeRate: 0.92
        )
    }

    // MARK: - Actions

    func selectDriver(_ id: UUID?) {
        selectedDriverID = id
        if let id, let driver = drivers.first(where: { $0.id == id }) {
            selectedDeliveryID = driver.currentDeliveryID
        }
    }

    func optimizeRoute(for driverID: UUID) {
        guard let routeIndex = routes.firstIndex(where: { $0.driverID == driverID }) else { return }

        // ウェイポイントの順序を最短距離で並び替え（簡易最適化）
        var waypoints = routes[routeIndex].waypoints
        if waypoints.count > 2 {
            let first = waypoints.removeFirst()
            let last = waypoints.removeLast()
            waypoints.sort { a, b in
                let distA = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                    .distance(from: CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude))
                let distB = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                    .distance(from: CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude))
                return distA < distB
            }
            waypoints.insert(first, at: 0)
            waypoints.append(last)
        }

        routes[routeIndex].waypoints = waypoints
        routes[routeIndex].isOptimized = true

        // ポリラインを再生成
        if waypoints.count >= 3 {
            routes[routeIndex].polylineCoordinates = generatePolyline(
                from: waypoints[0].coordinate,
                through: waypoints[1].coordinate,
                to: waypoints[2].coordinate
            )
            routes[routeIndex].totalDistance = calculateDistance(routes[routeIndex].polylineCoordinates)
            routes[routeIndex].estimatedDuration *= 0.85
        }
    }
}
