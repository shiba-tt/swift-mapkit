import MapKit
import SwiftUI

/// 商圏分析のメインマップビュー
struct TradeAreaMapView: View {
    @Bindable var viewModel: TradeAreaViewModel

    var body: some View {
        Map(position: $viewModel.cameraPosition, interactionModes: .all) {
            // --- 距離圏リング ---
            if viewModel.showDistanceRings {
                ForEach(viewModel.visibleRings) { ring in
                    // 塗りつぶし
                    MapCircle(center: viewModel.config.center, radius: ring.radius)
                        .foregroundStyle(ring.color.opacity(0.06))

                    // 枠線
                    MapCircle(center: viewModel.config.center, radius: ring.radius)
                        .stroke(ring.color, lineWidth: 2)
                }
            }

            // --- テリトリーポリゴン ---
            if viewModel.showTerritories {
                ForEach(viewModel.territories) { territory in
                    MapPolygon(coordinates: territory.polygon)
                        .foregroundStyle(territory.color.opacity(0.15))

                    MapPolygon(coordinates: territory.polygon)
                        .stroke(territory.color.opacity(0.6), lineWidth: 1.5)
                }
            }

            // --- 影響圏 ---
            if viewModel.showInfluenceZones {
                ForEach(viewModel.influenceZones) { zone in
                    MapCircle(
                        center: zone.competitor.coordinate,
                        radius: zone.radius
                    )
                    .foregroundStyle(zone.competitor.category.color.opacity(0.1))

                    MapCircle(
                        center: zone.competitor.coordinate,
                        radius: zone.radius
                    )
                    .stroke(zone.competitor.category.color.opacity(0.4), lineWidth: 1)
                }
            }

            // --- 中心マーカー ---
            Annotation("分析中心", coordinate: viewModel.config.center) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 28, height: 28)
                        .shadow(radius: 3)
                    Image(systemName: "target")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.red)
                }
            }

            // --- 競合マーカー ---
            ForEach(viewModel.competitors) { competitor in
                Annotation(
                    competitor.name,
                    coordinate: competitor.coordinate,
                    anchor: .bottom
                ) {
                    CompetitorMarker(competitor: competitor)
                        .onTapGesture {
                            viewModel.selectedCompetitor = competitor
                        }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .onMapCameraChange { context in
            // カメラ変更の追跡（必要に応じて拡張可能）
        }
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
    }
}

/// 競合マーカーの表示コンポーネント
struct CompetitorMarker: View {
    let competitor: Competitor

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(competitor.category.color)
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                Image(systemName: competitor.category.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }

            // 吹き出しの三角形
            Triangle()
                .fill(competitor.category.color)
                .frame(width: 10, height: 6)
        }
    }
}

/// マーカー下部の三角形シェイプ
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
