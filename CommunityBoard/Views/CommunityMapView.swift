import SwiftUI
import MapKit

/// メインのマップビュー
struct CommunityMapView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var locationManager: LocationManager
    @State private var mapSelection: Post?

    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $viewModel.cameraPosition, selection: $mapSelection) {
                    // ユーザー位置
                    UserAnnotation()

                    // 投稿マーカー
                    ForEach(viewModel.filteredPosts) { post in
                        Annotation(post.title, coordinate: post.coordinate, anchor: .bottom) {
                            PostAnnotationView(post: post)
                        }
                        .tag(post)
                    }

                    // 新規投稿位置マーカー
                    if let coord = viewModel.newPostCoordinate {
                        Annotation("新規投稿", coordinate: coord, anchor: .bottom) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                                .background(Circle().fill(.accent).frame(width: 40, height: 40))
                                .shadow(radius: 4)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.restaurant, .cafe, .park, .store])))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                    MapUserLocationButton()
                    MapPitchToggle()
                }
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        viewModel.handleMapTap(at: coordinate)
                    }
                }
                .onChange(of: mapSelection) { _, newValue in
                    if let post = newValue {
                        viewModel.selectedPost = post
                        viewModel.showingPostDetail = true
                        mapSelection = nil
                    }
                }
            }

            // オーバーレイUI
            VStack {
                // 上部: 検索バーとカテゴリ統計
                topBar

                Spacer()

                // 下部: アクションボタン
                bottomBar
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.showingPostDetail) {
            if let post = viewModel.selectedPost {
                PostDetailView(viewModel: viewModel, post: post)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $viewModel.showingCreatePost) {
            CreatePostView(viewModel: viewModel, locationManager: locationManager)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showingFilterPanel) {
            FilterPanelView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showingPostList) {
            PostListView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showingProfile) {
            ProfileView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 8) {
            // 検索バー
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("投稿を検索...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            // カテゴリ統計バー
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.postsByCategory, id: \.0) { category, count in
                        categoryChip(category: category, count: count)
                    }
                }
            }
        }
    }

    private func categoryChip(category: PostCategory, count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption2)
            Text("\(count)")
                .font(.caption2.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            viewModel.selectedCategories.contains(category)
                ? category.color.opacity(0.2)
                : Color.gray.opacity(0.1),
            in: Capsule()
        )
        .foregroundStyle(
            viewModel.selectedCategories.contains(category)
                ? category.color
                : .secondary
        )
        .overlay(
            Capsule().stroke(
                viewModel.selectedCategories.contains(category)
                    ? category.color.opacity(0.5)
                    : Color.clear,
                lineWidth: 1
            )
        )
        .onTapGesture {
            withAnimation {
                if viewModel.selectedCategories.contains(category) {
                    viewModel.selectedCategories.remove(category)
                } else {
                    viewModel.selectedCategories.insert(category)
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            // 投稿リスト
            Button {
                viewModel.showingPostList = true
            } label: {
                Label("リスト", systemImage: "list.bullet")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
            }

            // フィルター
            Button {
                viewModel.showingFilterPanel = true
            } label: {
                Label("フィルター", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
            }

            Spacer()

            // 投稿数バッジ
            Text("\(viewModel.totalActivePosts)件")
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())

            Spacer()

            // プロフィール
            Button {
                viewModel.showingProfile = true
            } label: {
                Text(viewModel.currentUser.avatarEmoji)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }

            // 新規投稿ボタン
            Button {
                let center = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
                let coordinate = locationManager.userLocation ?? center
                viewModel.handleMapTap(at: coordinate)
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.accent, in: Circle())
                    .shadow(color: .accent.opacity(0.4), radius: 8, y: 4)
            }
        }
    }
}
