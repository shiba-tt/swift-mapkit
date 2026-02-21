import SwiftUI
import MapKit

// MARK: - カメラポジションデモ

/// MapCameraPosition の各種設定（region / camera / rect / automatic / userLocation）と
/// アニメーション付きのカメラ移動を試せるデモ
struct CameraPositionDemo: View {

    @State private var position: MapCameraPosition = .region(SampleData.tokyo.region)
    @State private var selectedCity: City? = SampleData.tokyo
    @State private var heading: Double = 0
    @State private var pitch: Double = 0
    @State private var distance: Double = 5000

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                ForEach(SampleData.cities) { city in
                    Marker(city.name, coordinate: city.coordinate)
                        .tint(city.id == selectedCity?.id ? .red : .blue)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .onMapCameraChange(frequency: .continuous) { context in
                // カメラ変更を監視（必要に応じてUI更新に利用可能）
            }

            VStack(spacing: 12) {
                cameraInfoPanel
                citySelector
                cameraControls
            }
            .padding()
        }
        .navigationTitle("カメラポジション")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - カメラ情報パネル

    private var cameraInfoPanel: some View {
        VStack(spacing: 4) {
            Text("カメラ設定")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            HStack {
                infoItem(label: "Heading", value: "\(Int(heading))°")
                infoItem(label: "Pitch", value: "\(Int(pitch))°")
                infoItem(label: "Distance", value: "\(Int(distance))m")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func infoItem(label: String, value: String) -> some View {
        VStack {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.monospaced())
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 都市セレクター

    private var citySelector: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("都市を選択（アニメーション移動）")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SampleData.cities) { city in
                        Button {
                            selectedCity = city
                            moveTo(city: city)
                        } label: {
                            Text(city.name)
                                .font(.callout)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCity?.id == city.id
                                        ? Color.blue.opacity(0.8)
                                        : Color.gray.opacity(0.3),
                                    in: Capsule()
                                )
                                .foregroundStyle(selectedCity?.id == city.id ? .white : .primary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - カメラコントロール

    private var cameraControls: some View {
        VStack(spacing: 10) {
            // Heading
            VStack(alignment: .leading, spacing: 4) {
                Text("Heading（方位）: \(Int(heading))°")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Slider(value: $heading, in: 0...360, step: 15) { editing in
                    if !editing { applyCameraSettings() }
                }
            }

            // Pitch
            VStack(alignment: .leading, spacing: 4) {
                Text("Pitch（傾き）: \(Int(pitch))°")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Slider(value: $pitch, in: 0...70, step: 5) { editing in
                    if !editing { applyCameraSettings() }
                }
            }

            // Distance
            VStack(alignment: .leading, spacing: 4) {
                Text("Distance（距離）: \(Int(distance))m")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Slider(value: $distance, in: 500...50000, step: 500) { editing in
                    if !editing { applyCameraSettings() }
                }
            }

            // 特殊カメラ位置
            HStack(spacing: 8) {
                Button("全都市表示") {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        position = .automatic
                    }
                }
                .buttonStyle(.bordered)
                .font(.caption)

                Button("俯瞰ビュー") {
                    heading = 45
                    pitch = 60
                    distance = 2000
                    applyCameraSettings()
                }
                .buttonStyle(.bordered)
                .font(.caption)

                Button("リセット") {
                    heading = 0
                    pitch = 0
                    distance = 5000
                    if let city = selectedCity {
                        moveTo(city: city)
                    }
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - カメラ操作

    private func moveTo(city: City) {
        withAnimation(.easeInOut(duration: 1.5)) {
            position = .camera(MapCamera(
                centerCoordinate: city.coordinate,
                distance: distance,
                heading: heading,
                pitch: pitch
            ))
        }
    }

    private func applyCameraSettings() {
        guard let city = selectedCity else { return }
        withAnimation(.easeInOut(duration: 0.8)) {
            position = .camera(MapCamera(
                centerCoordinate: city.coordinate,
                distance: distance,
                heading: heading,
                pitch: pitch
            ))
        }
    }
}

#Preview {
    NavigationStack {
        CameraPositionDemo()
    }
}
