import Foundation
import CoreLocation
import UIKit

/// 写真のGPS位置情報を保持するモデル
struct PhotoLocation: Identifiable, Equatable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    let assetLocalIdentifier: String
    var thumbnailImage: UIImage?

    /// 撮影順序（ルート表示用）
    var orderIndex: Int = 0

    static func == (lhs: PhotoLocation, rhs: PhotoLocation) -> Bool {
        lhs.id == rhs.id
    }
}

/// 撮影ルートの統計情報
struct RouteStatistics {
    let totalPhotos: Int
    let totalDistance: CLLocationDistance
    let startDate: Date?
    let endDate: Date?
    let duration: TimeInterval?

    var formattedDistance: String {
        if totalDistance >= 1000 {
            return String(format: "%.1f km", totalDistance / 1000)
        } else {
            return String(format: "%.0f m", totalDistance)
        }
    }

    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        } else {
            return "\(minutes)分"
        }
    }
}
