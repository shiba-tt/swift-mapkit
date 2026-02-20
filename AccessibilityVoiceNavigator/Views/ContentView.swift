import SwiftUI
import MapKit

/// メインコンテンツビュー
struct ContentView: View {
    @EnvironmentObject var viewModel: NavigationViewModel

    var body: some View {
        ZStack {
            // 地図表示
            MapDisplayView()
                .edgesIgnoringSafeArea(.all)
                .accessibilityLabel("地図")
                .accessibilityHint("現在地と経路を表示しています")

            VStack(spacing: 0) {
                // 検索バー
                if viewModel.navigationState == .idle || viewModel.navigationState == .searching {
                    DestinationSearchView()
                        .padding(.top, 8)
                }

                Spacer()

                // ナビゲーション中の情報パネル
                if viewModel.navigationState == .navigating {
                    NavigationPanelView()
                }

                // 経路発見時のコントロールパネル
                if viewModel.navigationState == .routeFound {
                    RouteConfirmationView()
                }

                // 到着画面
                if viewModel.navigationState == .arrived {
                    ArrivalView()
                }

                // エラー表示
                if case .error(let message) = viewModel.navigationState {
                    ErrorBannerView(message: message)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("アクセシビリティ音声ナビゲーター")
    }
}

/// 経路確認ビュー
struct RouteConfirmationView: View {
    @EnvironmentObject var viewModel: NavigationViewModel

    var body: some View {
        VStack(spacing: 16) {
            if let routeInfo = viewModel.routeInfo {
                // 経路情報
                VStack(spacing: 8) {
                    Text(viewModel.selectedDestination?.name ?? "目的地")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .accessibilityAddTraits(.isHeader)

                    HStack(spacing: 20) {
                        Label(routeInfo.totalDistanceText, systemImage: "figure.walk")
                        Label(routeInfo.totalTimeText, systemImage: "clock")
                        if let arrival = viewModel.estimatedArrivalTime {
                            Label(arrival, systemImage: "clock.badge.checkmark")
                                .accessibilityLabel("到着予想時刻 \(arrival)")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "\(viewModel.selectedDestination?.name ?? "目的地")まで、\(routeInfo.totalDistanceText)、\(routeInfo.totalTimeText)"
                )
            }

            HStack(spacing: 16) {
                // キャンセルボタン
                Button(action: { viewModel.stopNavigation() }) {
                    Label("キャンセル", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .accessibilityLabel("ナビゲーションをキャンセル")
                .accessibilityHint("経路を取り消して検索画面に戻ります")

                // 開始ボタン
                Button(action: { viewModel.startNavigation() }) {
                    Label("ナビ開始", systemImage: "location.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .accessibilityLabel("ナビゲーション開始")
                .accessibilityHint("音声ガイダンスによるナビゲーションを開始します")
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

/// 到着ビュー
struct ArrivalView: View {
    @EnvironmentObject var viewModel: NavigationViewModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
                .accessibilityHidden(true)

            Text("目的地に到着しました")
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            if let destination = viewModel.selectedDestination {
                Text(destination.name)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Button(action: { viewModel.stopNavigation() }) {
                Text("終了する")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("ナビゲーションを終了")
            .accessibilityHint("検索画面に戻ります")
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .accessibilityElement(children: .contain)
    }
}

/// エラーバナービュー
struct ErrorBannerView: View {
    let message: String
    @EnvironmentObject var viewModel: NavigationViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .accessibilityHidden(true)
                Text(message)
                    .font(.subheadline)
            }

            Button("閉じる") {
                viewModel.navigationState = .idle
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("エラーを閉じる")
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.95))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("エラー。\(message)")
    }
}
