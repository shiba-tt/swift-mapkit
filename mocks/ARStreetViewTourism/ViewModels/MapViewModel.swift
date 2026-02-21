import Foundation
import MapKit
import SwiftUI

/// マップ表示とLook Around機能を管理するViewModel
@MainActor
final class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671), // 東京駅
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @Published var selectedSpot: TouristSpot?
    @Published var lookAroundScene: MKLookAroundScene?
    @Published var isLoadingLookAround = false
    @Published var lookAroundAvailable = false
    @Published var searchText = ""
    @Published var selectedCategory: TouristSpot.Category?
    @Published var cameraPosition: MapCameraPosition = .automatic

    let allSpots = TouristSpot.sampleSpots

    var filteredSpots: [TouristSpot] {
        var spots = allSpots
        if let category = selectedCategory {
            spots = spots.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            spots = spots.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.nameJapanese.contains(searchText) ||
                $0.description.contains(searchText)
            }
        }
        return spots
    }

    /// 選択したスポットのLook Aroundシーンを取得
    func fetchLookAroundScene(for spot: TouristSpot) async {
        isLoadingLookAround = true
        lookAroundScene = nil
        lookAroundAvailable = false

        let request = MKLookAroundSceneRequest(
            coordinate: spot.coordinate
        )

        do {
            let scene = try await request.scene
            lookAroundScene = scene
            lookAroundAvailable = scene != nil
        } catch {
            print("Look Around scene fetch error: \(error.localizedDescription)")
            lookAroundAvailable = false
        }

        isLoadingLookAround = false
    }

    /// スポットを選択してカメラを移動
    func selectSpot(_ spot: TouristSpot) {
        selectedSpot = spot
        cameraPosition = .region(MKCoordinateRegion(
            center: spot.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
        Task {
            await fetchLookAroundScene(for: spot)
        }
    }

    /// 任意の座標でLook Aroundが利用可能かチェック
    func checkLookAroundAvailability(at coordinate: CLLocationCoordinate2D) async -> Bool {
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        do {
            let scene = try await request.scene
            return scene != nil
        } catch {
            return false
        }
    }

    /// エリアプリセット
    enum AreaPreset: String, CaseIterable {
        case tokyo = "東京"
        case kyoto = "京都"

        var region: MKCoordinateRegion {
            switch self {
            case .tokyo:
                return MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                )
            case .kyoto:
                return MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                )
            }
        }
    }

    func moveToArea(_ area: AreaPreset) {
        cameraPosition = .region(area.region)
        selectedSpot = nil
        lookAroundScene = nil
        lookAroundAvailable = false
    }
}
