import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PhotoMapViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isAuthorized {
                    photoMapContent
                } else if viewModel.authorizationStatus == .notDetermined {
                    loadingView
                } else {
                    accessDeniedView
                }
            }
            .navigationTitle("フォトマップ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.isAuthorized {
                    toolbarItems
                }
            }
            .task {
                await viewModel.requestPhotoAccess()
            }
            .sheet(item: $viewModel.selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
            }
            .sheet(isPresented: $viewModel.showPhotoList) {
                PhotoListView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Subviews

    private var photoMapContent: some View {
        ZStack(alignment: .bottom) {
            PhotoMapView(viewModel: viewModel)

            if viewModel.isLoading {
                ProgressView("写真を読み込み中...")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 80)
            }

            if !viewModel.isLoading && !viewModel.hasPhotos {
                emptyStateView
            }

            if let stats = viewModel.routeStatistics, viewModel.hasPhotos {
                RouteInfoBar(statistics: stats, showRoute: viewModel.showRoute)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("フォトライブラリへのアクセスを確認中...")
                .foregroundStyle(.secondary)
        }
    }

    private var accessDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("写真へのアクセスが必要です")
                .font(.title2)
                .fontWeight(.semibold)

            Text("フォトマップを使用するには、設定からフォトライブラリへのアクセスを許可してください。")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("設定を開く") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "map")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("GPS情報付きの写真がありません")
                .font(.headline)

            Text("位置情報が記録された写真を撮影すると\nマップに自動配置されます")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                Task { await viewModel.loadPhotos() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                viewModel.showRoute.toggle()
            } label: {
                Image(systemName: viewModel.showRoute
                    ? "point.topleft.down.to.point.bottomright.curvepath.fill"
                    : "point.topleft.down.to.point.bottomright.curvepath")
            }

            Button {
                viewModel.showPhotoList.toggle()
            } label: {
                Image(systemName: "photo.stack")
            }

            Button {
                viewModel.fitMapToPhotos()
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
            }
        }
    }
}

#Preview {
    ContentView()
}
