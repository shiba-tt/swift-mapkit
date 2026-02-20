import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel = FieldworkViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Map Tab
            mapTab
                .tabItem {
                    Label("マップ", systemImage: "map.fill")
                }
                .tag(0)

            // Records Tab
            PointListView(viewModel: viewModel)
                .tabItem {
                    Label("記録一覧", systemImage: "list.bullet")
                }
                .tag(1)
        }
        .sheet(isPresented: $viewModel.showPointDetail) {
            if let point = viewModel.selectedPoint {
                SurveyPointDetailView(viewModel: viewModel, point: point)
            }
        }
        .sheet(isPresented: $viewModel.showNewPointEditor) {
            NewPointEditorView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showBoundaryNaming) {
            BoundaryNamingView(viewModel: viewModel)
        }
        .alert("お知らせ", isPresented: $viewModel.showAlert) {
            Button("OK") {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }

    @ViewBuilder
    private var mapTab: some View {
        ZStack(alignment: .bottom) {
            MapContainerView(viewModel: viewModel)
                .ignoresSafeArea(edges: .top)

            // Bottom toolbar
            mapToolbar
                .padding(.bottom, 8)
        }
    }

    private var mapToolbar: some View {
        HStack(spacing: 0) {
            ForEach(InteractionMode.allCases, id: \.rawValue) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if viewModel.interactionMode == mode {
                            viewModel.interactionMode = .browse
                        } else {
                            if mode == .drawBoundary {
                                viewModel.boundaryVertices = []
                            }
                            viewModel.interactionMode = mode
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: modeIcon(mode))
                            .font(.system(size: 20))
                        Text(mode.rawValue)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        viewModel.interactionMode == mode
                            ? Color.accentColor.opacity(0.15)
                            : Color.clear
                    )
                    .foregroundStyle(
                        viewModel.interactionMode == mode
                            ? Color.accentColor
                            : .primary
                    )
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        .padding(.horizontal, 16)
    }

    private func modeIcon(_ mode: InteractionMode) -> String {
        switch mode {
        case .browse: "binoculars.fill"
        case .addPoint: "mappin.and.ellipse"
        case .drawBoundary: "pencil.and.outline"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [SurveyPoint.self, AreaBoundary.self], inMemory: true)
}
