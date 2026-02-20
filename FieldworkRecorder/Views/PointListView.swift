import SwiftUI
import SwiftData
import MapKit

struct PointListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SurveyPoint.createdAt, order: .reverse) private var points: [SurveyPoint]
    @Query(sort: \AreaBoundary.createdAt, order: .reverse) private var boundaries: [AreaBoundary]
    @Bindable var viewModel: FieldworkViewModel

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            Picker("表示", selection: $selectedTab) {
                Text("調査地点 (\(points.count))").tag(0)
                Text("エリア (\(boundaries.count))").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Group {
                if selectedTab == 0 {
                    pointsList
                } else {
                    boundariesList
                }
            }
            .navigationTitle("記録一覧")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Points List

    @ViewBuilder
    private var pointsList: some View {
        if points.isEmpty {
            ContentUnavailableView(
                "調査地点がありません",
                systemImage: "mappin.slash",
                description: Text("マップをタップして調査地点を追加してください")
            )
        } else {
            List {
                ForEach(points) { point in
                    Button {
                        viewModel.selectedPoint = point
                        viewModel.showPointDetail = true
                        viewModel.cameraPosition = .region(
                            MKCoordinateRegion(
                                center: point.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            )
                        )
                    } label: {
                        PointRowView(point: point)
                    }
                    .tint(.primary)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deletePoint(points[index], modelContext: modelContext)
                    }
                }
            }
        }
    }

    // MARK: - Boundaries List

    @ViewBuilder
    private var boundariesList: some View {
        if boundaries.isEmpty {
            ContentUnavailableView(
                "エリア境界がありません",
                systemImage: "square.dashed",
                description: Text("エリア描画モードでマップ上にエリアを描いてください")
            )
        } else {
            List {
                ForEach(boundaries) { boundary in
                    BoundaryRowView(boundary: boundary)
                        .onTapGesture {
                            if let center = boundaryCenter(boundary) {
                                viewModel.cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: center,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                )
                            }
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteBoundary(boundaries[index], modelContext: modelContext)
                    }
                }
            }
        }
    }

    private func boundaryCenter(_ boundary: AreaBoundary) -> CLLocationCoordinate2D? {
        let coords = boundary.coordinates
        guard !coords.isEmpty else { return nil }
        let lat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
        let lon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// MARK: - Point Row

struct PointRowView: View {
    let point: SurveyPoint

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: point.categoryIcon)
                .font(.title3)
                .foregroundStyle(categoryColor)
                .frame(width: 36, height: 36)
                .background(categoryColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(point.title.isEmpty ? "無題の地点" : point.title)
                    .font(.subheadline.bold())

                HStack(spacing: 8) {
                    Text(point.createdAt, style: .date)
                    if !point.note.isEmpty {
                        Image(systemName: "note.text")
                    }
                    if !point.photoFileNames.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "photo")
                            Text("\(point.photoFileNames.count)")
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }

    private var categoryColor: Color {
        switch point.category {
        case "flora": .green
        case "fauna": .orange
        case "geology": .brown
        case "water": .blue
        case "structure": .purple
        default: .red
        }
    }
}

// MARK: - Boundary Row

struct BoundaryRowView: View {
    let boundary: AreaBoundary

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: boundary.colorHex).opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: boundary.colorHex), lineWidth: 2)
                )
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(boundary.name.isEmpty ? "無題のエリア" : boundary.name)
                    .font(.subheadline.bold())
                HStack(spacing: 8) {
                    Text(boundary.createdAt, style: .date)
                    Text("\(boundary.coordinates.count)頂点")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
