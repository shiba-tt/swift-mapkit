import SwiftUI
import MapKit

// MARK: - デモ一覧

enum DemoItem: String, CaseIterable, Identifiable {
    case mapStyle = "マップスタイル"
    case markersAnnotations = "マーカー & アノテーション"
    case overlays = "オーバーレイ"
    case mapControls = "マップコントロール"
    case cameraPosition = "カメラポジション"
    case lookAround = "Look Around"
    case search = "場所検索"
    case interaction = "インタラクション"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .mapStyle: return "map"
        case .markersAnnotations: return "mappin.and.ellipse"
        case .overlays: return "square.on.circle"
        case .mapControls: return "slider.horizontal.3"
        case .cameraPosition: return "camera.viewfinder"
        case .lookAround: return "binoculars"
        case .search: return "magnifyingglass"
        case .interaction: return "hand.tap"
        }
    }

    var description: String {
        switch self {
        case .mapStyle:
            return "Standard / Imagery / Hybrid スタイルと各種オプション"
        case .markersAnnotations:
            return "Marker・Annotationの表示とカスタマイズ"
        case .overlays:
            return "Circle・Polygon・Polylineオーバーレイ"
        case .mapControls:
            return "Compass・Pitch・Scale・Zoomなどのコントロール"
        case .cameraPosition:
            return "カメラ位置のプログラム制御とアニメーション"
        case .lookAround:
            return "Look Aroundによるストリートビュー表示"
        case .search:
            return "MKLocalSearchによる場所の検索"
        case .interaction:
            return "タップ選択・地図上のインタラクション"
        }
    }
}

// MARK: - メインコンテンツビュー

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(DemoItem.allCases) { item in
                NavigationLink(value: item) {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.rawValue)
                                .font(.headline)
                            Text(item.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: item.icon)
                            .foregroundStyle(.blue)
                            .frame(width: 30)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("MapKit Explorer")
            .navigationDestination(for: DemoItem.self) { item in
                demoView(for: item)
            }
        }
    }

    @ViewBuilder
    private func demoView(for item: DemoItem) -> some View {
        switch item {
        case .mapStyle:
            MapStyleDemo()
        case .markersAnnotations:
            MarkersAnnotationsDemo()
        case .overlays:
            OverlaysDemo()
        case .mapControls:
            MapControlsDemo()
        case .cameraPosition:
            CameraPositionDemo()
        case .lookAround:
            LookAroundDemo()
        case .search:
            SearchDemo()
        case .interaction:
            InteractionDemo()
        }
    }
}

#Preview {
    ContentView()
}
