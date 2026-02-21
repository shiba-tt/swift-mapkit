import SwiftUI
import MapKit

// MARK: - マーカー & アノテーション デモ

/// Marker（システム標準のバルーンピン）と Annotation（カスタムSwiftUIビュー）の
/// 各種カスタマイズオプションを試せるデモ
struct MarkersAnnotationsDemo: View {

    enum DisplayMode: String, CaseIterable, Identifiable {
        case markers = "Marker"
        case annotations = "Annotation"
        case mixed = "混合"
        var id: String { rawValue }
    }

    @State private var displayMode: DisplayMode = .markers
    @State private var selectedCategory: Landmark.Category? = nil
    @State private var selectedLandmark: Landmark? = nil
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    private var filteredLandmarks: [Landmark] {
        guard let category = selectedCategory else {
            return SampleData.tokyoLandmarks
        }
        return SampleData.tokyoLandmarks.filter { $0.category == category }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position, selection: $selectedLandmark) {
                switch displayMode {
                case .markers:
                    markerContent
                case .annotations:
                    annotationContent
                case .mixed:
                    markerContent
                    annotationContent
                }
            }
            .mapStyle(.standard(elevation: .realistic))

            VStack(spacing: 12) {
                // 選択されたランドマーク情報
                if let landmark = selectedLandmark {
                    selectedLandmarkCard(landmark)
                }

                controlPanel
            }
            .padding()
        }
        .navigationTitle("マーカー & アノテーション")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Markerコンテンツ

    @MapContentBuilder
    private var markerContent: some MapContent {
        ForEach(filteredLandmarks) { landmark in
            Marker(landmark.name,
                   systemImage: landmark.systemImage,
                   coordinate: landmark.coordinate)
            .tint(colorForCategory(landmark.category))
            .tag(landmark)
        }
    }

    // MARK: - Annotationコンテンツ

    @MapContentBuilder
    private var annotationContent: some MapContent {
        ForEach(filteredLandmarks) { landmark in
            Annotation(landmark.name, coordinate: landmark.coordinate, anchor: .bottom) {
                VStack(spacing: 2) {
                    Image(systemName: landmark.systemImage)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(colorForCategory(landmark.category).gradient)
                        .clipShape(Circle())
                        .shadow(radius: 3)

                    Text(landmark.name)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .tag(landmark)
        }
    }

    // MARK: - 選択ランドマークカード

    private func selectedLandmarkCard(_ landmark: Landmark) -> some View {
        HStack {
            Image(systemName: landmark.systemImage)
                .font(.title2)
                .foregroundStyle(colorForCategory(landmark.category))
            VStack(alignment: .leading) {
                Text(landmark.name)
                    .font(.headline)
                Text("カテゴリ: \(landmark.category.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.4f, %.4f",
                            landmark.coordinate.latitude,
                            landmark.coordinate.longitude))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - コントロールパネル

    private var controlPanel: some View {
        VStack(spacing: 10) {
            // 表示モード
            Picker("表示モード", selection: $displayMode) {
                ForEach(DisplayMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            // カテゴリフィルター
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryFilterButton(nil, label: "すべて")
                    ForEach(Landmark.Category.allCases, id: \.self) { category in
                        categoryFilterButton(category, label: category.rawValue)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func categoryFilterButton(_ category: Landmark.Category?, label: String) -> some View {
        Button {
            withAnimation {
                selectedCategory = category
            }
        } label: {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    selectedCategory == category
                        ? Color.blue.opacity(0.8)
                        : Color.gray.opacity(0.3),
                    in: Capsule()
                )
                .foregroundStyle(selectedCategory == category ? .white : .primary)
        }
    }

    // MARK: - カテゴリ色

    private func colorForCategory(_ category: Landmark.Category) -> Color {
        switch category {
        case .temple: return .red
        case .tower: return .orange
        case .park: return .green
        case .station: return .blue
        case .shopping: return .purple
        }
    }
}

#Preview {
    NavigationStack {
        MarkersAnnotationsDemo()
    }
}
