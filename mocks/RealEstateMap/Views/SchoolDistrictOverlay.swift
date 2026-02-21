import SwiftUI
import MapKit

/// 学区のMapPolygonオーバーレイ
struct SchoolDistrictOverlay: MapContent {
    let districts: [SchoolDistrict]

    var body: some MapContent {
        ForEach(districts) { district in
            MapPolygon(coordinates: district.boundary)
                .foregroundStyle(fillColor(for: district).opacity(0.2))
                .stroke(strokeColor(for: district), lineWidth: 2)

            // 学区名ラベル
            Annotation(district.name, coordinate: centroid(of: district.boundary)) {
                Text(district.name)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(labelBackground(for: district))
                    )
                    .foregroundStyle(.white)
            }
        }
    }

    private func fillColor(for district: SchoolDistrict) -> Color {
        switch district.level {
        case .elementary: return .blue
        case .juniorHigh: return .green
        }
    }

    private func strokeColor(for district: SchoolDistrict) -> Color {
        switch district.level {
        case .elementary: return .blue.opacity(0.8)
        case .juniorHigh: return .green.opacity(0.8)
        }
    }

    private func labelBackground(for district: SchoolDistrict) -> Color {
        switch district.level {
        case .elementary: return .blue.opacity(0.85)
        case .juniorHigh: return .green.opacity(0.85)
        }
    }

    /// ポリゴンの重心を計算
    private func centroid(of coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !coordinates.isEmpty else {
            return CLLocationCoordinate2D()
        }
        let totalLat = coordinates.reduce(0.0) { $0 + $1.latitude }
        let totalLon = coordinates.reduce(0.0) { $0 + $1.longitude }
        let count = Double(coordinates.count)
        return CLLocationCoordinate2D(
            latitude: totalLat / count,
            longitude: totalLon / count
        )
    }
}
