import Photos
import UIKit
import CoreLocation

/// フォトライブラリからGPS情報付き写真を取得するサービス
enum PhotoLibraryService {

    static func requestAuthorization() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }

    /// GPS位置情報を持つ写真を撮影日時順に取得
    static func fetchPhotosWithLocation() async -> [PhotoLocation] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(
            format: "mediaType == %d",
            PHAssetMediaType.image.rawValue
        )
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]

        let assets = PHAsset.fetchAssets(with: fetchOptions)
        var photos: [PhotoLocation] = []

        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat
        requestOptions.resizeMode = .fast

        let thumbnailSize = CGSize(width: 120, height: 120)

        assets.enumerateObjects { asset, index, _ in
            guard let location = asset.location,
                  let creationDate = asset.creationDate else {
                return
            }

            var photo = PhotoLocation(
                id: asset.localIdentifier,
                coordinate: location.coordinate,
                timestamp: creationDate,
                assetLocalIdentifier: asset.localIdentifier,
                orderIndex: 0
            )

            imageManager.requestImage(
                for: asset,
                targetSize: thumbnailSize,
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in
                photo.thumbnailImage = image
            }

            photos.append(photo)
        }

        // 撮影日時順にソートし、順序インデックスを設定
        let sorted = photos
            .sorted { $0.timestamp < $1.timestamp }
            .enumerated()
            .map { index, photo -> PhotoLocation in
                var p = photo
                p.orderIndex = index + 1
                return p
            }

        return sorted
    }

    /// フル解像度の写真を取得
    static func fetchFullImage(for identifier: String) async -> UIImage? {
        let assets = PHAsset.fetchAssets(
            withLocalIdentifiers: [identifier],
            options: nil
        )
        guard let asset = assets.firstObject else { return nil }

        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                // degraded imageでない場合のみ返す
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    /// ルート統計情報を計算
    static func calculateRouteStatistics(for photos: [PhotoLocation]) -> RouteStatistics {
        var totalDistance: CLLocationDistance = 0

        for i in 1..<photos.count {
            let prev = CLLocation(
                latitude: photos[i - 1].coordinate.latitude,
                longitude: photos[i - 1].coordinate.longitude
            )
            let curr = CLLocation(
                latitude: photos[i].coordinate.latitude,
                longitude: photos[i].coordinate.longitude
            )
            totalDistance += prev.distance(from: curr)
        }

        let startDate = photos.first?.timestamp
        let endDate = photos.last?.timestamp
        let duration: TimeInterval? = if let s = startDate, let e = endDate {
            e.timeIntervalSince(s)
        } else {
            nil
        }

        return RouteStatistics(
            totalPhotos: photos.count,
            totalDistance: totalDistance,
            startDate: startDate,
            endDate: endDate,
            duration: duration
        )
    }
}
