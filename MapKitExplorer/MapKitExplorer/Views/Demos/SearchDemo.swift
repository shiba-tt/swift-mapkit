import SwiftUI
import MapKit

// MARK: - 場所検索デモ

/// MKLocalSearch を使った場所検索のデモ。
/// 自然言語検索とカテゴリ検索の両方を試せる。
struct SearchDemo: View {

    @State private var position: MapCameraPosition = .region(SampleData.tokyo.region)
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem? = nil
    @State private var isSearching = false
    @State private var visibleRegion: MKCoordinateRegion? = nil

    // カテゴリ検索用
    private let searchCategories: [(String, MKPointOfInterestCategory)] = [
        ("カフェ", .cafe),
        ("レストラン", .restaurant),
        ("ホテル", .hotel),
        ("公園", .park),
        ("博物館", .museum),
        ("病院", .hospital),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position, selection: $selectedResult) {
                ForEach(searchResults, id: \.self) { item in
                    if let name = item.name {
                        Marker(name, systemImage: "mappin",
                               coordinate: item.placemark.coordinate)
                        .tint(.red)
                        .tag(item)
                    }
                }
            }
            .mapStyle(.standard)
            .onMapCameraChange(frequency: .onEnd) { context in
                visibleRegion = context.region
            }

            VStack(spacing: 12) {
                // 選択結果の詳細
                if let item = selectedResult {
                    searchResultDetail(item)
                }

                searchPanel
            }
            .padding()
        }
        .navigationTitle("場所検索")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 検索パネル

    private var searchPanel: some View {
        VStack(spacing: 10) {
            // テキスト検索
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("場所を検索...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performSearch()
                    }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                        selectedResult = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(10)
            .background(.background, in: RoundedRectangle(cornerRadius: 10))

            // カテゴリボタン
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(searchCategories, id: \.0) { name, category in
                        Button {
                            performCategorySearch(category)
                        } label: {
                            Text(name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.15), in: Capsule())
                        }
                    }
                }
            }

            // 検索結果数
            if !searchResults.isEmpty {
                Text("\(searchResults.count) 件の結果")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 検索結果詳細

    private func searchResultDetail(_ item: MKMapItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let name = item.name {
                Text(name)
                    .font(.headline)
            }
            if let address = item.placemark.title {
                Text(address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                if let phone = item.phoneNumber {
                    Label(phone, systemImage: "phone")
                        .font(.caption)
                }
                if let url = item.url {
                    Link(destination: url) {
                        Label("Web", systemImage: "safari")
                            .font(.caption)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 検索実行

    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        selectedResult = nil

        Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            if let region = visibleRegion {
                request.region = region
            }
            request.resultTypes = .pointOfInterest

            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                await MainActor.run {
                    searchResults = response.mapItems
                    isSearching = false

                    // 結果にフィットするようにカメラを調整
                    if !searchResults.isEmpty {
                        withAnimation {
                            position = .automatic
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    searchResults = []
                    isSearching = false
                }
            }
        }
    }

    private func performCategorySearch(_ category: MKPointOfInterestCategory) {
        isSearching = true
        selectedResult = nil

        Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = category.rawValue
            if let region = visibleRegion {
                request.region = region
            } else {
                request.region = SampleData.tokyo.region
            }
            request.resultTypes = .pointOfInterest

            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                await MainActor.run {
                    searchResults = response.mapItems
                    isSearching = false
                    if !searchResults.isEmpty {
                        withAnimation {
                            position = .automatic
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    searchResults = []
                    isSearching = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchDemo()
    }
}
