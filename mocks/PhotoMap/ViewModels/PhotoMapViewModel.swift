import SwiftUI
import MapKit
import Photos

@MainActor
final class PhotoMapViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var photos: [PhotoLocation] = []
    @Published var selectedPhoto: PhotoLocation?
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var showRoute = true
    @Published var showPhotoList = false
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var routeStatistics: RouteStatistics?

    // MARK: - Computed Properties

    /// ルート描画用の座標配列（撮影日時順）
    var routeCoordinates: [CLLocationCoordinate2D] {
        photos.map(\.coordinate)
    }

    var hasPhotos: Bool {
        !photos.isEmpty
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }

    // MARK: - Actions

    /// フォトライブラリへのアクセスを要求し、写真を読み込む
    func requestPhotoAccess() async {
        authorizationStatus = await PhotoLibraryService.requestAuthorization()
        if isAuthorized {
            await loadPhotos()
        }
    }

    /// GPS情報付き写真を読み込む
    func loadPhotos() async {
        isLoading = true
        defer { isLoading = false }

        photos = await PhotoLibraryService.fetchPhotosWithLocation()
        routeStatistics = PhotoLibraryService.calculateRouteStatistics(for: photos)

        if hasPhotos {
            fitMapToPhotos()
        }
    }

    /// 全写真が収まるようにマップの表示範囲を調整
    func fitMapToPhotos() {
        guard !photos.isEmpty else { return }

        let coordinates = photos.map(\.coordinate)
        let minLat = coordinates.map(\.latitude).min()!
        let maxLat = coordinates.map(\.latitude).max()!
        let minLon = coordinates.map(\.longitude).min()!
        let maxLon = coordinates.map(\.longitude).max()!

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let latDelta = (maxLat - minLat) * 1.4 + 0.005
        let lonDelta = (maxLon - minLon) * 1.4 + 0.005

        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: latDelta,
                longitudeDelta: lonDelta
            )
        )

        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(region)
        }
    }

    /// 写真を選択
    func selectPhoto(_ photo: PhotoLocation) {
        selectedPhoto = photo
    }

    /// 特定の写真にカメラを移動
    func focusOnPhoto(_ photo: PhotoLocation) {
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: photo.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }
}
