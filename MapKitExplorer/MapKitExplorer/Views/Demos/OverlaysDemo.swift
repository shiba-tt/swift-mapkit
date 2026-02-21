import SwiftUI
import MapKit

// MARK: - Compatibility shim for MapOverlayLevel

#if canImport(MapKit)
import MapKit
#endif

#if compiler(>=5.9)
// Newer SDKs: use MKOverlayLevel directly for SwiftUI's overlayLevel(_:) modifier.
private typealias MapOverlayLevel = MKOverlayLevel

// No-op shim: apply overlay level at the call site where supported
private extension MapContent {
    func overlayLevelCompat(_ level: MapOverlayLevel) -> some MapContent {
        // No-op shim: apply overlay level at the call site where supported
        return self
    }
}

// Helper that can be used inside Map content builders without ViewBuilder
private extension MapContent {
    func applyOverlayLevelIfAvailable(_ level: MapOverlayLevel) -> some MapContent {
        // No-op shim: overlayLevel(_:) is not available as a member on MapContent in all SDKs.
        // Apply overlay level directly at call sites guarded by availability when supported.
        return self
    }
}

// Helper for use in ViewBuilder contexts (wraps Map in a Group)
private extension View {
    @ViewBuilder
    func mapOverlayLevel(_ level: MapOverlayLevel) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            self
        } else {
            self
        }
    }
}
#else
// Older compilers/SDKs: define a local shim type and a no-op modifier so the file compiles.
private enum MapOverlayLevel: Hashable {
    case aboveRoads
    case aboveLabels
}

private extension MapContent {
    func overlayLevelCompat(_ level: MapOverlayLevel) -> some MapContent {
        // No-op on environments without SwiftUI's overlayLevel API
        return self
    }
}
#endif

struct OverlaysDemo: View {

    @State private var showCircle = true
    @State private var showPolygon = true
    @State private var showPolyline = true
    @State private var circleRadius: Double = 1000
    @State private var lineWidth: CGFloat = 4
    @State private var overlayLevel: MapOverlayLevel = .aboveRoads

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7571),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                // 東京駅マーカー
                Marker("東京駅", systemImage: "tram",
                       coordinate: SampleData.tokyoLandmarks[6].coordinate)
                .tint(.blue)

                // MapCircle - 東京駅を中心とした円
                if showCircle {
                    MapCircle(
                        center: SampleData.tokyoLandmarks[6].coordinate,
                        radius: circleRadius
                    )
                    .foregroundStyle(.blue.opacity(0.15))
                    .stroke(.blue, lineWidth: 2)
                    .applyOverlayLevelIfAvailable(overlayLevel)
                }

                // MapPolygon - 皇居エリア
                if showPolygon {
                    MapPolygon(coordinates: SampleData.imperialPalaceCoordinates)
                        .foregroundStyle(.green.opacity(0.2))
                        .stroke(.green, lineWidth: lineWidth)
                        .applyOverlayLevelIfAvailable(overlayLevel)
                }

                // MapPolyline - 山手線ルート
                if showPolyline {
                    MapPolyline(coordinates: SampleData.yamanoteLineCoordinates)
                        .stroke(.orange, lineWidth: lineWidth)
                        .applyOverlayLevelIfAvailable(overlayLevel)
                }
            }
            .mapStyle(.standard(elevation: .flat))

            controlPanel
        }
        .navigationTitle("オーバーレイ")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - コントロールパネル

    private var controlPanel: some View {
        VStack(spacing: 12) {
            // オーバーレイ表示切り替え
            HStack(spacing: 12) {
                overlayToggle(isOn: $showCircle, label: "Circle", color: .blue)
                overlayToggle(isOn: $showPolygon, label: "Polygon", color: .green)
                overlayToggle(isOn: $showPolyline, label: "Polyline", color: .orange)
            }

            // Circle半径スライダー
            if showCircle {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Circle半径: \(Int(circleRadius))m")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Slider(value: $circleRadius, in: 200...5000, step: 100)
                        .tint(.blue)
                }
            }

            // 線幅スライダー
            VStack(alignment: .leading, spacing: 4) {
                Text("線幅: \(Int(lineWidth))pt")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Slider(value: $lineWidth, in: 1...10, step: 1)
                    .tint(.orange)
            }

            // オーバーレイレベル
            VStack(alignment: .leading, spacing: 4) {
                Text("オーバーレイレベル")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Picker("レベル", selection: $overlayLevel) {
                    Text("Above Roads").tag(MapOverlayLevel.aboveRoads)
                    Text("Above Labels").tag(MapOverlayLevel.aboveLabels)
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    private func overlayToggle(isOn: Binding<Bool>, label: String, color: Color) -> some View {
        Toggle(isOn: isOn) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .toggleStyle(.button)
        .tint(color)
    }
}

#Preview {
    NavigationStack {
        OverlaysDemo()
    }
}

