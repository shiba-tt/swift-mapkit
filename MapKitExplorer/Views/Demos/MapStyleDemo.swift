import SwiftUI
import MapKit

// MARK: - マップスタイルデモ

/// Standard / Imagery / Hybrid の3スタイルと、Elevation・交通情報・POI表示の切り替えを試せるデモ
struct MapStyleDemo: View {

    // MARK: スタイル選択

    enum StyleType: String, CaseIterable, Identifiable {
        case standard = "Standard"
        case imagery = "Imagery"
        case hybrid = "Hybrid"
        var id: String { rawValue }
    }

    enum ElevationType: String, CaseIterable, Identifiable {
        case flat = "Flat"
        case realistic = "Realistic"
        var id: String { rawValue }
    }

    @State private var selectedStyle: StyleType = .standard
    @State private var selectedElevation: ElevationType = .flat
    @State private var showsTraffic = false
    @State private var showPointsOfInterest = true

    @State private var position: MapCameraPosition = .region(SampleData.tokyo.region)

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                // 東京タワーにマーカーを配置して位置の目印に
                Marker("東京タワー", systemImage: "antenna.radiowaves.left.and.right",
                       coordinate: SampleData.tokyoLandmarks[0].coordinate)
            }
            .mapStyle(currentMapStyle)
            .animation(.easeInOut, value: selectedStyle)
            .animation(.easeInOut, value: selectedElevation)

            // コントロールパネル
            controlPanel
        }
        .navigationTitle("マップスタイル")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 現在のマップスタイル

    private var currentMapStyle: MapStyle {
        let elevation: MapStyle.Elevation = selectedElevation == .realistic ? .realistic : .flat
        let poi: PointOfInterestCategories = showPointsOfInterest ? .all : .excludingAll

        switch selectedStyle {
        case .standard:
            return .standard(elevation: elevation, pointsOfInterest: poi, showsTraffic: showsTraffic)
        case .imagery:
            return .imagery(elevation: elevation)
        case .hybrid:
            return .hybrid(elevation: elevation, pointsOfInterest: poi, showsTraffic: showsTraffic)
        }
    }

    // MARK: - コントロールパネル

    private var controlPanel: some View {
        VStack(spacing: 12) {
            // スタイル切り替え
            VStack(alignment: .leading, spacing: 6) {
                Text("スタイル")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Picker("スタイル", selection: $selectedStyle) {
                    ForEach(StyleType.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Elevation切り替え
            VStack(alignment: .leading, spacing: 6) {
                Text("Elevation（3D表示）")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Picker("Elevation", selection: $selectedElevation) {
                    ForEach(ElevationType.allCases) { elev in
                        Text(elev.rawValue).tag(elev)
                    }
                }
                .pickerStyle(.segmented)
            }

            // オプション
            HStack(spacing: 16) {
                Toggle(isOn: $showsTraffic) {
                    Label("交通情報", systemImage: "car")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .disabled(selectedStyle == .imagery)

                Toggle(isOn: $showPointsOfInterest) {
                    Label("POI", systemImage: "mappin")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .disabled(selectedStyle == .imagery)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}

#Preview {
    NavigationStack {
        MapStyleDemo()
    }
}
