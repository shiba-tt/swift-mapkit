import SwiftUI
import MapKit

/// 駅からの徒歩圏をMapCircleで表示するオーバーレイ
struct StationCircleOverlay: MapContent {
    let stations: [Station]
    let walkingMinutes: Int

    var body: some MapContent {
        ForEach(stations) { station in
            let radius = Double(walkingMinutes) * 80.0

            // 徒歩圏の円
            MapCircle(center: station.coordinate, radius: radius)
                .foregroundStyle(.orange.opacity(0.12))
                .stroke(.orange.opacity(0.6), lineWidth: 2)

            // 駅マーカー
            Annotation(station.name, coordinate: station.coordinate) {
                VStack(spacing: 2) {
                    Image(systemName: "tram.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Circle().fill(.orange))
                        .shadow(radius: 3)

                    Text(station.name)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.orange.opacity(0.9))
                        )
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
