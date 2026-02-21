import SwiftUI
import MapKit

/// Main view containing the map, filter panel, and legend
struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showFilterPanel = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Map
            EnvironmentalMapView(viewModel: viewModel)
                .ignoresSafeArea()

            // Top-right controls
            VStack(spacing: 12) {
                // Filter toggle button
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showFilterPanel.toggle()
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }

                // Filter panel
                if showFilterPanel {
                    FilterPanelView(viewModel: viewModel)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.top, 60)
            .padding(.trailing, 12)

            // Legend (bottom-left)
            VStack {
                Spacer()
                HStack {
                    LegendView(viewModel: viewModel)
                        .padding(.leading, 12)
                        .padding(.bottom, 40)
                    Spacer()
                }
            }

            // Title bar overlay
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("環境観測マップ")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("東京・新宿エリア")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

                    Spacer()
                }
                .padding(.top, 56)
                .padding(.leading, 12)

                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.showDetailSheet) {
            DetailSheetView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ContentView()
}
