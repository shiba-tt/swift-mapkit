import SwiftUI

/// 目的地検索ビュー
struct DestinationSearchView: View {
    @EnvironmentObject var viewModel: NavigationViewModel
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)

                TextField("目的地を検索", text: $viewModel.searchQuery)
                    .focused($isSearchFieldFocused)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .accessibilityLabel("目的地検索")
                    .accessibilityHint("目的地の名前や住所を入力してください")
                    .onSubmit {
                        Task {
                            await viewModel.searchDestination()
                        }
                    }

                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                        viewModel.searchResults = []
                        viewModel.showSearchResults = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("検索をクリア")
                    .accessibilityHint("検索テキストと結果をクリアします")
                }

                // 検索ボタン
                Button(action: {
                    isSearchFieldFocused = false
                    Task {
                        await viewModel.searchDestination()
                    }
                }) {
                    Text("検索")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityLabel("検索を実行")
                .accessibilityHint("入力した目的地を検索します")
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.horizontal, 16)

            // 検索結果リスト
            if viewModel.showSearchResults {
                SearchResultsListView()
                    .padding(.top, 4)
            }
        }
    }
}

/// 検索結果リストビュー
struct SearchResultsListView: View {
    @EnvironmentObject var viewModel: NavigationViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.searchResults) { item in
                    SearchResultRow(item: item)
                        .onTapGesture {
                            Task {
                                await viewModel.selectDestination(item)
                            }
                        }
                }
            }
        }
        .frame(maxHeight: 300)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
        .accessibilityLabel("検索結果一覧")
    }
}

/// 検索結果の行
struct SearchResultRow: View {
    let item: SearchResultItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundColor(.red)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(item.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name)、\(item.address)")
        .accessibilityHint("ダブルタップで目的地に設定します")
        .accessibilityAddTraits(.isButton)
    }
}
