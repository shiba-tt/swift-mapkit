import Foundation
import MapKit

/// MKLocalSearchを使用して周辺の競合店舗を自動検出するサービス
actor CompetitorSearchService {
    /// 指定カテゴリで周辺の競合を検索
    func search(
        category: SearchCategory,
        center: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Competitor] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category.searchQuery
        request.region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)

        return response.mapItems
            .map { Competitor(from: $0, center: center, category: category) }
            .filter { competitor in
                let location = CLLocation(
                    latitude: competitor.coordinate.latitude,
                    longitude: competitor.coordinate.longitude
                )
                return centerLocation.distance(from: location) <= radius
            }
            .sorted { $0.distance < $1.distance }
    }

    /// 複数カテゴリで一括検索
    func searchAll(
        categories: Set<SearchCategory>,
        center: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Competitor] {
        var allCompetitors: [Competitor] = []

        // Apple APIのレート制限を考慮し、逐次実行
        for category in categories.sorted(by: { $0.rawValue < $1.rawValue }) {
            do {
                let competitors = try await search(
                    category: category,
                    center: center,
                    radius: radius
                )
                allCompetitors.append(contentsOf: competitors)

                // APIレート制限対策の待機
                try await Task.sleep(for: .milliseconds(500))
            } catch {
                // 個別カテゴリの失敗は無視して続行
                continue
            }
        }

        return removeDuplicates(from: allCompetitors)
    }

    /// 名前と座標が近い重複を除去
    private func removeDuplicates(from competitors: [Competitor]) -> [Competitor] {
        var seen: [String: Competitor] = [:]

        for competitor in competitors {
            // 名前＋おおよその座標でキーを生成
            let latKey = String(format: "%.4f", competitor.coordinate.latitude)
            let lonKey = String(format: "%.4f", competitor.coordinate.longitude)
            let key = "\(competitor.name)_\(latKey)_\(lonKey)"

            if seen[key] == nil {
                seen[key] = competitor
            }
        }

        return Array(seen.values).sorted { $0.distance < $1.distance }
    }
}
