import SwiftUI
import MapKit

// MARK: - インタラクションデモ

/// マップ上でのタップによるピン追加、長押しでのアノテーション追加、
/// 距離計算などのインタラクション機能を試せるデモ
struct InteractionDemo: View {

    struct DroppedPin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let timestamp: Date
    }

    @State private var position: MapCameraPosition = .region(SampleData.tokyo.region)
    @State private var droppedPins: [DroppedPin] = []
    @State private var selectedPin: DroppedPin? = nil
    @State private var showDistance = true
    @State private var interactionMode: MapInteractionModes = .all

    // インタラクションモードの選択肢
    enum InteractionOption: String, CaseIterable, Identifiable {
        case all = "すべて"
        case pan = "パンのみ"
        case zoom = "ズームのみ"
        case rotate = "回転のみ"
        case pitch = "ピッチのみ"
        var id: String { rawValue }

        var mode: MapInteractionModes {
            switch self {
            case .all: return .all
            case .pan: return .pan
            case .zoom: return .zoom
            case .rotate: return .rotate
            case .pitch: return .pitch
            }
        }
    }

    @State private var selectedInteraction: InteractionOption = .all

    var body: some View {
        ZStack(alignment: .bottom) {
            MapReader { proxy in
                Map(position: $position, interactionModes: selectedInteraction.mode) {
                    // ドロップされたピン
                    ForEach(droppedPins) { pin in
                        Annotation("", coordinate: pin.coordinate) {
                            VStack(spacing: 2) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.red)
                                    .shadow(radius: 2)
                                Text(timeString(pin.timestamp))
                                    .font(.system(size: 9))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                    }

                    // ピン間の距離ライン
                    if showDistance && droppedPins.count >= 2 {
                        let coords = droppedPins.map(\.coordinate)
                        MapPolyline(coordinates: coords)
                            .stroke(.blue, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .onTapGesture { screenCoord in
                    if let coordinate = proxy.convert(screenCoord, from: .local) {
                        let newPin = DroppedPin(coordinate: coordinate, timestamp: Date())
                        withAnimation {
                            droppedPins.append(newPin)
                        }
                    }
                }
            }

            VStack(spacing: 12) {
                // 距離情報
                if showDistance && droppedPins.count >= 2 {
                    distanceInfo
                }

                controlPanel
            }
            .padding()
        }
        .navigationTitle("インタラクション")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 距離情報

    private var distanceInfo: some View {
        VStack(spacing: 4) {
            Text("総距離")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(totalDistanceString)
                .font(.title3.monospaced())
                .fontWeight(.bold)
                .foregroundStyle(.blue)
            Text("\(droppedPins.count) 地点")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - コントロールパネル

    private var controlPanel: some View {
        VStack(spacing: 10) {
            Text("地図をタップしてピンを追加")
                .font(.caption)
                .foregroundStyle(.secondary)

            // インタラクションモード選択
            VStack(alignment: .leading, spacing: 4) {
                Text("インタラクションモード")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(InteractionOption.allCases) { option in
                            Button {
                                selectedInteraction = option
                            } label: {
                                Text(option.rawValue)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        selectedInteraction == option
                                            ? Color.blue.opacity(0.8)
                                            : Color.gray.opacity(0.3),
                                        in: Capsule()
                                    )
                                    .foregroundStyle(selectedInteraction == option ? .white : .primary)
                            }
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Toggle(isOn: $showDistance) {
                    Label("距離表示", systemImage: "ruler")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .tint(.blue)

                Button(role: .destructive) {
                    withAnimation {
                        droppedPins.removeAll()
                    }
                } label: {
                    Label("全削除", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .disabled(droppedPins.isEmpty)

                if droppedPins.count > 0 {
                    Button {
                        withAnimation {
                            droppedPins.removeLast()
                        }
                    } label: {
                        Label("1つ戻す", systemImage: "arrow.uturn.backward")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - ヘルパー

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private var totalDistanceString: String {
        guard droppedPins.count >= 2 else { return "0 m" }

        var total: CLLocationDistance = 0
        for i in 0..<(droppedPins.count - 1) {
            let loc1 = CLLocation(
                latitude: droppedPins[i].coordinate.latitude,
                longitude: droppedPins[i].coordinate.longitude
            )
            let loc2 = CLLocation(
                latitude: droppedPins[i + 1].coordinate.latitude,
                longitude: droppedPins[i + 1].coordinate.longitude
            )
            total += loc1.distance(from: loc2)
        }

        if total >= 1000 {
            return String(format: "%.2f km", total / 1000)
        } else {
            return String(format: "%.0f m", total)
        }
    }
}

#Preview {
    NavigationStack {
        InteractionDemo()
    }
}
