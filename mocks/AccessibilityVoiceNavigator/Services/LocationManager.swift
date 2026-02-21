import Foundation
import CoreLocation
import Combine

/// 位置情報を管理するサービス
final class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var heading: CLHeading?
    @Published var locationError: String?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // 5メートルごとに更新
        locationManager.activityType = .fitness // 歩行ナビゲーション向け
    }

    /// 位置情報の利用許可をリクエスト
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// 位置情報の取得を開始
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    /// 位置情報の取得を停止
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    /// 現在地の座標を返す
    var currentCoordinate: CLLocationCoordinate2D? {
        currentLocation?.coordinate
    }

    /// 指定座標までの距離を計算
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let current = currentLocation else { return nil }
        let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return current.distance(from: target)
    }

    /// 指定座標への方角を計算
    func bearing(to coordinate: CLLocationCoordinate2D) -> Double? {
        guard let current = currentCoordinate else { return nil }

        let lat1 = current.latitude.toRadians()
        let lon1 = current.longitude.toRadians()
        let lat2 = coordinate.latitude.toRadians()
        let lon2 = coordinate.longitude.toRadians()

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let bearing = atan2(y, x).toDegrees()
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    /// 現在の向きと目標方角から相対的な方向指示を生成
    func relativeDirection(to coordinate: CLLocationCoordinate2D) -> String? {
        guard let targetBearing = bearing(to: coordinate),
              let currentHeading = heading?.trueHeading else {
            return nil
        }

        var relativeBearing = targetBearing - currentHeading
        if relativeBearing < 0 { relativeBearing += 360 }

        switch relativeBearing {
        case 0..<23, 338..<360:
            return "まっすぐ進んでください"
        case 23..<68:
            return "右斜め前方です"
        case 68..<113:
            return "右方向です"
        case 113..<158:
            return "右斜め後方です"
        case 158..<203:
            return "後方です。Uターンしてください"
        case 203..<248:
            return "左斜め後方です"
        case 248..<293:
            return "左方向です"
        case 293..<338:
            return "左斜め前方です"
        default:
            return nil
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // 精度が100m以内のデータのみ採用
        guard location.horizontalAccuracy <= 100 else { return }
        currentLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
            locationError = nil
        case .denied:
            locationError = "位置情報の利用が拒否されています。設定アプリから許可してください。"
        case .restricted:
            locationError = "位置情報の利用が制限されています。"
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = "位置情報の取得に失敗しました: \(error.localizedDescription)"
    }
}

// MARK: - Double Extensions for Angle Conversion
private extension Double {
    func toRadians() -> Double {
        self * .pi / 180.0
    }

    func toDegrees() -> Double {
        self * 180.0 / .pi
    }
}
