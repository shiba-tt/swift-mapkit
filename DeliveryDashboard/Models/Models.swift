import Foundation
import CoreLocation
import MapKit

// MARK: - Driver

struct Driver: Identifiable {
    let id: UUID
    var name: String
    var coordinate: CLLocationCoordinate2D
    var heading: Double
    var status: DriverStatus
    var vehicleType: VehicleType
    var currentDeliveryID: UUID?
    var completedCount: Int

    enum DriverStatus: String, CaseIterable {
        case idle = "待機中"
        case enRoute = "配達中"
        case delivering = "配達先到着"
        case returning = "帰還中"

        var color: String {
            switch self {
            case .idle: return "gray"
            case .enRoute: return "blue"
            case .delivering: return "orange"
            case .returning: return "green"
            }
        }

        var systemImage: String {
            switch self {
            case .idle: return "pause.circle.fill"
            case .enRoute: return "car.fill"
            case .delivering: return "shippingbox.fill"
            case .returning: return "arrow.uturn.left.circle.fill"
            }
        }
    }

    enum VehicleType: String, CaseIterable {
        case car = "車"
        case bike = "バイク"
        case bicycle = "自転車"

        var systemImage: String {
            switch self {
            case .car: return "car.fill"
            case .bike: return "motorcycle.fill"
            case .bicycle: return "bicycle"
            }
        }
    }
}

// MARK: - Delivery

struct Delivery: Identifiable {
    let id: UUID
    var orderNumber: String
    var pickupLocation: CLLocationCoordinate2D
    var pickupAddress: String
    var dropoffLocation: CLLocationCoordinate2D
    var dropoffAddress: String
    var status: DeliveryStatus
    var assignedDriverID: UUID?
    var estimatedArrival: Date?
    var createdAt: Date

    enum DeliveryStatus: String, CaseIterable {
        case pending = "未割当"
        case assigned = "割当済"
        case pickedUp = "集荷完了"
        case inTransit = "配送中"
        case delivered = "配達完了"
        case failed = "配達失敗"

        var color: String {
            switch self {
            case .pending: return "gray"
            case .assigned: return "blue"
            case .pickedUp: return "indigo"
            case .inTransit: return "orange"
            case .delivered: return "green"
            case .failed: return "red"
            }
        }
    }
}

// MARK: - Route

struct DeliveryRoute: Identifiable {
    let id: UUID
    var driverID: UUID
    var waypoints: [Waypoint]
    var polylineCoordinates: [CLLocationCoordinate2D]
    var totalDistance: CLLocationDistance
    var estimatedDuration: TimeInterval
    var isOptimized: Bool

    struct Waypoint: Identifiable {
        let id: UUID
        var coordinate: CLLocationCoordinate2D
        var label: String
        var type: WaypointType
        var order: Int

        enum WaypointType {
            case pickup
            case dropoff
            case warehouse
        }
    }
}

// MARK: - Dashboard Stats

struct DashboardStats {
    var totalDeliveries: Int
    var completedDeliveries: Int
    var activeDrivers: Int
    var idleDrivers: Int
    var averageDeliveryTime: TimeInterval
    var onTimeRate: Double

    var completionRate: Double {
        guard totalDeliveries > 0 else { return 0 }
        return Double(completedDeliveries) / Double(totalDeliveries)
    }
}
