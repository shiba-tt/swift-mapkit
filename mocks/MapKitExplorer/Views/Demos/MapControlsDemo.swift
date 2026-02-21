import SwiftUI
import MapKit

// MARK: - マップコントロールデモ

/// MapCompass / MapPitchToggle / MapScaleView / MapUserLocationButton /
/// MapZoomStepper などの組み込みコントロールを試せるデモ
struct MapControlsDemo: View {

    @State private var showCompass = true
    @State private var showScale = true
    @State private var showPitchToggle = true
    @State private var showUserLocationButton = true
    @State private var showZoomStepper = true

    @State private var position: MapCameraPosition = .region(SampleData.tokyo.region)

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                ForEach(SampleData.tokyoLandmarks) { landmark in
                    Marker(landmark.name,
                           systemImage: landmark.systemImage,
                           coordinate: landmark.coordinate)
                    .tint(.blue)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                if showCompass {
                    MapCompass()
                }
                if showScale {
                    MapScaleView()
                }
                if showPitchToggle {
                    MapPitchToggle()
                }
                if showUserLocationButton {
                    MapUserLocationButton()
                }
                if showZoomStepper {
                    MapZoomStepper()
                }
            }

            controlPanel
        }
        .navigationTitle("マップコントロール")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - コントロールパネル

    private var controlPanel: some View {
        VStack(spacing: 8) {
            Text("コントロール表示切り替え")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 8) {
                controlToggle(isOn: $showCompass, icon: "safari", label: "Compass")
                controlToggle(isOn: $showScale, icon: "ruler", label: "Scale")
                controlToggle(isOn: $showPitchToggle, icon: "rotate.3d", label: "Pitch")
                controlToggle(isOn: $showUserLocationButton, icon: "location", label: "Location")
                controlToggle(isOn: $showZoomStepper, icon: "plus.magnifyingglass", label: "Zoom")
            }

            Text("地図を回転するとCompassが表示されます\nPitchボタンで3D/2D切り替えができます")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    private func controlToggle(isOn: Binding<Bool>, icon: String, label: String) -> some View {
        Toggle(isOn: isOn) {
            Label(label, systemImage: icon)
                .font(.caption)
                .fontWeight(.medium)
        }
        .toggleStyle(.button)
        .tint(.blue)
    }
}

#Preview {
    NavigationStack {
        MapControlsDemo()
    }
}
