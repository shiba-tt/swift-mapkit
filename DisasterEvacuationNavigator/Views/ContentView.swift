import SwiftUI
import MapKit

/// メインコンテンツビュー
struct ContentView: View {
    @StateObject private var viewModel = EvacuationViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            // マップ
            EvacuationMapView(viewModel: viewModel)
                .ignoresSafeArea(edges: .top)

            // オーバーレイUI
            VStack(spacing: 0) {
                Spacer()

                // 凡例（左下）+ ボタン群（右下）
                HStack(alignment: .bottom) {
                    FloodZoneLegendView(showFloodZones: $viewModel.showFloodZones)
                        .frame(width: 160)

                    Spacer()

                    VStack(spacing: 10) {
                        // 避難所一覧ボタン
                        MapActionButton(
                            icon: "list.bullet",
                            label: "一覧"
                        ) {
                            viewModel.showShelterList = true
                        }

                        // 最寄り避難所ボタン
                        MapActionButton(
                            icon: "figure.walk.arrival",
                            label: "最寄り",
                            color: .red
                        ) {
                            viewModel.navigateToNearest()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // 避難所詳細パネル
                if let shelter = viewModel.selectedShelter {
                    ShelterDetailView(
                        shelter: shelter,
                        location: viewModel.locationManager.effectiveLocation,
                        estimatedTravelTime: viewModel.estimatedTravelTime,
                        estimatedDistance: viewModel.estimatedDistance,
                        isLoadingRoute: viewModel.isLoadingRoute,
                        routeError: viewModel.routeError,
                        onClose: {
                            withAnimation { viewModel.clearSelection() }
                        },
                        onNavigate: {
                            openInAppleMaps(shelter: shelter)
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 8)
                }
            }
        }
        .sheet(isPresented: $viewModel.showShelterList) {
            ShelterListView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.setup()
        }
    }

    /// Apple Mapsで経路案内を開く
    private func openInAppleMaps(shelter: EvacuationShelter) {
        let placemark = MKPlacemark(coordinate: shelter.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = shelter.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}

/// マップ上のアクションボタン
struct MapActionButton: View {
    let icon: String
    let label: String
    var color: Color = .accentColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .frame(width: 52, height: 52)
            .background(.ultraThinMaterial)
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 2)
        }
    }
}
