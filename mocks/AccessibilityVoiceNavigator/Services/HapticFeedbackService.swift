import UIKit

/// 触覚フィードバックを管理するサービス
final class HapticFeedbackService {
    static let shared = HapticFeedbackService()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    /// ジェネレーターを事前準備
    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    /// 方向転換時のフィードバック
    func turnFeedback() {
        impactMedium.impactOccurred()
    }

    /// 到着時のフィードバック
    func arrivalFeedback() {
        notification.notificationOccurred(.success)
    }

    /// ナビゲーション開始時のフィードバック
    func navigationStartFeedback() {
        impactHeavy.impactOccurred()
    }

    /// 経路逸脱時のフィードバック
    func offRouteFeedback() {
        notification.notificationOccurred(.warning)
    }

    /// エラー時のフィードバック
    func errorFeedback() {
        notification.notificationOccurred(.error)
    }

    /// 選択時のフィードバック
    func selectionFeedback() {
        selection.selectionChanged()
    }

    /// 定期的な位置確認フィードバック（軽い振動）
    func locationPulseFeedback() {
        impactLight.impactOccurred()
    }
}
