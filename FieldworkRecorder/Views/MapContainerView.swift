import SwiftUI
import MapKit
import SwiftData

struct MapContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var surveyPoints: [SurveyPoint]
    @Query private var boundaries: [AreaBoundary]
    @Bindable var viewModel: FieldworkViewModel

    var body: some View {
        ZStack(alignment: .top) {
            MapReader { proxy in
                Map(position: $viewModel.cameraPosition) {
                    // Survey point annotations
                    ForEach(surveyPoints) { point in
                        Annotation(
                            point.title,
                            coordinate: point.coordinate,
                            anchor: .bottom
                        ) {
                            SurveyPointMarker(point: point)
                                .onTapGesture {
                                    viewModel.selectedPoint = point
                                    viewModel.showPointDetail = true
                                }
                        }
                    }

                    // Area boundaries
                    ForEach(boundaries) { boundary in
                        if boundary.coordinates.count >= 3 {
                            MapPolygon(coordinates: boundary.coordinates)
                                .foregroundStyle(
                                    Color(hex: boundary.colorHex).opacity(0.2)
                                )
                                .stroke(
                                    Color(hex: boundary.colorHex),
                                    lineWidth: 2
                                )
                        }
                    }

                    // Boundary drawing in progress
                    if !viewModel.boundaryVertices.isEmpty {
                        // Show vertices
                        ForEach(
                            Array(viewModel.boundaryVertices.enumerated()),
                            id: \.offset
                        ) { index, coord in
                            Annotation("", coordinate: coord) {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Text("\(index + 1)")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                            }
                        }

                        // Show lines between vertices
                        if viewModel.boundaryVertices.count >= 2 {
                            MapPolyline(coordinates: viewModel.boundaryVertices)
                                .stroke(.red, lineWidth: 2)
                        }

                        // Show closing line preview
                        if viewModel.boundaryVertices.count >= 3 {
                            MapPolygon(coordinates: viewModel.boundaryVertices)
                                .foregroundStyle(.red.opacity(0.1))
                                .stroke(.red.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        }
                    }

                    UserAnnotation()
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .mapStyle(.hybrid(elevation: .realistic))
                .onTapGesture { screenCoord in
                    if let coordinate = proxy.convert(screenCoord, from: .local) {
                        viewModel.handleMapTap(at: coordinate, modelContext: modelContext)
                    }
                }
            }

            // Mode indicator
            if viewModel.interactionMode != .browse {
                ModeIndicatorView(viewModel: viewModel)
            }

            // Boundary drawing controls
            if viewModel.interactionMode == .drawBoundary && !viewModel.boundaryVertices.isEmpty {
                VStack {
                    Spacer()
                    BoundaryDrawingControls(viewModel: viewModel, modelContext: modelContext)
                        .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Survey Point Marker

struct SurveyPointMarker: View {
    let point: SurveyPoint

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: point.categoryIcon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(categoryColor)
                .clipShape(Circle())
                .shadow(radius: 3)

            Image(systemName: "triangle.fill")
                .font(.system(size: 8))
                .foregroundStyle(categoryColor)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
        }
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

// MARK: - Mode Indicator

struct ModeIndicatorView: View {
    let viewModel: FieldworkViewModel

    var body: some View {
        HStack {
            Image(systemName: viewModel.interactionMode == .addPoint ? "mappin.and.ellipse" : "pencil.and.outline")
                .font(.subheadline)
            Text(modeMessage)
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(radius: 4)
        .padding(.top, 8)
    }

    private var modeMessage: String {
        switch viewModel.interactionMode {
        case .browse: ""
        case .addPoint: "マップをタップして地点を追加"
        case .drawBoundary: "マップをタップして頂点を追加 (\(viewModel.boundaryVertices.count)点)"
        }
    }
}

// MARK: - Boundary Drawing Controls

struct BoundaryDrawingControls: View {
    @Bindable var viewModel: FieldworkViewModel
    let modelContext: ModelContext

    var body: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.cancelBoundaryDrawing()
                viewModel.interactionMode = .browse
            } label: {
                Label("取消", systemImage: "xmark")
                    .font(.subheadline.bold())
            }
            .buttonStyle(.bordered)
            .tint(.red)

            Button {
                if !viewModel.boundaryVertices.isEmpty {
                    viewModel.boundaryVertices.removeLast()
                }
            } label: {
                Label("1つ戻す", systemImage: "arrow.uturn.backward")
                    .font(.subheadline.bold())
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.boundaryVertices.isEmpty)

            Button {
                viewModel.showBoundaryNaming = true
            } label: {
                Label("完了", systemImage: "checkmark")
                    .font(.subheadline.bold())
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.boundaryVertices.count < 3)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
