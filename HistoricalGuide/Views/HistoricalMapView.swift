import SwiftUI
import MapKit

/// 歴史散策マップのメインビュー
struct HistoricalMapView: View {
    @ObservedObject var viewModel: HistoricalSiteViewModel
    @Namespace private var mapScope

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // メインマップ
            Map(position: $viewModel.cameraPosition, scope: mapScope) {
                // 史跡のアノテーション
                ForEach(viewModel.filteredSites) { site in
                    Annotation(site.name, coordinate: site.coordinate) {
                        SiteAnnotationView(
                            site: site,
                            isSelected: viewModel.selectedSite?.id == site.id,
                            isFavorite: viewModel.isFavorite(site)
                        )
                        .onTapGesture {
                            viewModel.selectSite(site)
                        }
                    }
                }

                // ルート表示
                if viewModel.isShowingRoute, !viewModel.routePolyline.isEmpty {
                    MapPolyline(coordinates: viewModel.routePolyline)
                        .stroke(.blue, lineWidth: 4)
                }
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.museum, .park, .temple])))
            .mapControls {
                MapCompass(scope: mapScope)
                MapScaleView(scope: mapScope)
                MapUserLocationButton(scope: mapScope)
            }
            .mapScope(mapScope)

            // オーバーレイコントロール
            VStack(spacing: 12) {
                // 地域選択ボタン
                RegionPickerButton(viewModel: viewModel)

                // フィルタボタン
                FilterButton(viewModel: viewModel)

                // 全表示ボタン
                Button {
                    viewModel.showAllSites()
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }

                // ルート表示中の解除ボタン
                if viewModel.isShowingRoute {
                    Button {
                        viewModel.clearRoute()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.red)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
            .padding(.trailing, 12)
            .padding(.top, 60)

            // 選択中のルート情報バナー
            if viewModel.isShowingRoute, let route = viewModel.selectedRoute {
                VStack {
                    Spacer()
                    RouteInfoBanner(route: route, sites: viewModel.routeSites) {
                        viewModel.clearRoute()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingDetail) {
            if let site = viewModel.selectedSite {
                SiteDetailView(site: site, viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingAR) {
            if let site = viewModel.selectedSite {
                ARHistoricalView(site: site) {
                    viewModel.isShowingAR = false
                }
            }
        }
    }
}

// MARK: - Region Picker Button

struct RegionPickerButton: View {
    @ObservedObject var viewModel: HistoricalSiteViewModel

    var body: some View {
        Menu {
            ForEach(MapRegion.allCases) { region in
                Button(region.rawValue) {
                    viewModel.moveToRegion(region)
                }
            }
        } label: {
            Image(systemName: "map.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

// MARK: - Filter Button

struct FilterButton: View {
    @ObservedObject var viewModel: HistoricalSiteViewModel
    @State private var isShowingFilter = false

    private var hasActiveFilter: Bool {
        viewModel.selectedEraFilter != nil || viewModel.selectedCategoryFilter != nil
    }

    var body: some View {
        Button {
            isShowingFilter = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())

                if hasActiveFilter {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 2, y: -2)
                }
            }
        }
        .sheet(isPresented: $isShowingFilter) {
            FilterSheetView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Filter Sheet

struct FilterSheetView: View {
    @ObservedObject var viewModel: HistoricalSiteViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // 時代フィルタ
                Section("時代で絞り込み") {
                    ForEach(HistoricalEra.allCases) { era in
                        Button {
                            if viewModel.selectedEraFilter == era {
                                viewModel.selectedEraFilter = nil
                            } else {
                                viewModel.selectedEraFilter = era
                            }
                        } label: {
                            HStack {
                                Text(era.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(era.yearRange)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if viewModel.selectedEraFilter == era {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // カテゴリフィルタ
                Section("カテゴリで絞り込み") {
                    ForEach(SiteCategory.allCases) { category in
                        Button {
                            if viewModel.selectedCategoryFilter == category {
                                viewModel.selectedCategoryFilter = nil
                            } else {
                                viewModel.selectedCategoryFilter = category
                            }
                        } label: {
                            HStack {
                                Image(systemName: category.iconName)
                                    .frame(width: 24)
                                Text(category.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if viewModel.selectedCategoryFilter == category {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("フィルタ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("リセット") {
                        viewModel.clearFilters()
                    }
                    .disabled(viewModel.selectedEraFilter == nil && viewModel.selectedCategoryFilter == nil)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Route Info Banner

struct RouteInfoBanner: View {
    let route: WalkingRoute
    let sites: [HistoricalSite]
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: route.difficulty.iconName)
                    .foregroundStyle(.blue)
                Text(route.name)
                    .font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            Text(route.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Label("\(route.estimatedDurationMinutes)分", systemImage: "clock")
                Label(String(format: "%.1fkm", route.distanceKilometers), systemImage: "figure.walk")
                Label(route.difficulty.rawValue, systemImage: "gauge.medium")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            // ルート上の史跡
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(sites.enumerated()), id: \.element.id) { index, site in
                        HStack(spacing: 4) {
                            if index > 0 {
                                Image(systemName: "arrow.right")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text(site.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1), in: Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
