import Foundation
import MapKit
import UIKit

/// Custom renderer that draws a heatmap visualization from environmental data points
final class HeatmapOverlayRenderer: MKOverlayRenderer {

    private let heatmapOverlay: HeatmapOverlay

    init(overlay: HeatmapOverlay) {
        self.heatmapOverlay = overlay
        super.init(overlay: overlay)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard !heatmapOverlay.dataPoints.isEmpty else { return }

        let overlayRect = self.overlay.boundingMapRect
        let drawRect = self.rect(for: overlayRect)

        // Resolution of the heatmap grid
        let tileSize: CGFloat = max(drawRect.width / 80, 4)
        let cols = Int(drawRect.width / tileSize) + 1
        let rows = Int(drawRect.height / tileSize) + 1

        // Pre-compute map points for each data point
        let dataMapPoints = heatmapOverlay.dataPoints.map { dp -> (mapPoint: MKMapPoint, intensity: Double) in
            (MKMapPoint(dp.coordinate), dp.intensity)
        }

        let radiusInMapPoints = MKMapPointsPerMeterAtLatitude(heatmapOverlay.coordinate.latitude) * heatmapOverlay.radius

        context.setBlendMode(.normal)

        for row in 0..<rows {
            for col in 0..<cols {
                let cellX = drawRect.origin.x + CGFloat(col) * tileSize
                let cellY = drawRect.origin.y + CGFloat(row) * tileSize
                let cellRect = CGRect(x: cellX, y: cellY, width: tileSize, height: tileSize)

                // Convert cell center to map point
                let cellMapPoint = self.mapPoint(for: CGPoint(
                    x: cellX + tileSize / 2,
                    y: cellY + tileSize / 2
                ))

                // Calculate weighted intensity from all data points
                var totalWeight: Double = 0
                var weightedIntensity: Double = 0

                for dp in dataMapPoints {
                    let dx = cellMapPoint.x - dp.mapPoint.x
                    let dy = cellMapPoint.y - dp.mapPoint.y
                    let distSq = dx * dx + dy * dy
                    let radiusSq = radiusInMapPoints * radiusInMapPoints

                    if distSq < radiusSq {
                        // Gaussian-like falloff
                        let normalizedDist = distSq / radiusSq
                        let weight = exp(-3.0 * normalizedDist)
                        totalWeight += weight
                        weightedIntensity += dp.intensity * weight
                    }
                }

                guard totalWeight > 0 else { continue }

                let intensity = weightedIntensity / totalWeight
                let alpha = min(totalWeight * 0.3, 0.6)  // Semi-transparent

                let color = Self.colorForIntensity(
                    intensity,
                    dataType: heatmapOverlay.dataType,
                    alpha: alpha
                )

                context.setFillColor(color)
                context.fill(cellRect)
            }
        }
    }

    // MARK: - Color Mapping

    /// Maps an intensity value (0–1) to a color
    /// Air quality: Green (good) → Yellow → Orange → Red (bad)
    /// Noise: Blue (quiet) → Cyan → Yellow → Red (loud)
    private static func colorForIntensity(
        _ intensity: Double,
        dataType: HeatmapDataType,
        alpha: Double
    ) -> CGColor {
        let t = min(max(intensity, 0), 1)
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat

        switch dataType {
        case .airQuality:
            // Green → Yellow → Orange → Red
            if t < 0.25 {
                let s = CGFloat(t / 0.25)
                r = 0.2 * s
                g = 0.7 + 0.2 * s
                b = 0.3 * (1 - s)
            } else if t < 0.5 {
                let s = CGFloat((t - 0.25) / 0.25)
                r = 0.2 + 0.6 * s
                g = 0.9 - 0.1 * s
                b = 0
            } else if t < 0.75 {
                let s = CGFloat((t - 0.5) / 0.25)
                r = 0.8 + 0.2 * s
                g = 0.8 - 0.4 * s
                b = 0
            } else {
                let s = CGFloat((t - 0.75) / 0.25)
                r = 1.0
                g = 0.4 - 0.4 * s
                b = 0
            }

        case .noise:
            // Blue → Cyan → Yellow → Red
            if t < 0.33 {
                let s = CGFloat(t / 0.33)
                r = 0
                g = 0.3 + 0.5 * s
                b = 0.8 - 0.3 * s
            } else if t < 0.66 {
                let s = CGFloat((t - 0.33) / 0.33)
                r = 0.5 * s
                g = 0.8
                b = 0.5 * (1 - s)
            } else {
                let s = CGFloat((t - 0.66) / 0.34)
                r = 0.5 + 0.5 * s
                g = 0.8 - 0.6 * s
                b = 0
            }
        }

        return CGColor(
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            components: [r, g, b, CGFloat(alpha)]
        )!
    }
}
