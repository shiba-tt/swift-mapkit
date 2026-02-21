import Foundation
import AVFoundation
import Combine

/// 音声ガイダンスを管理するサービス（日本語対応）
final class VoiceGuidanceService: NSObject, ObservableObject {
    @Published var isSpeaking = false
    @Published var isEnabled = true
    @Published var speechRate: Float = 0.5 // 0.0〜1.0

    private let synthesizer = AVSpeechSynthesizer()
    private var speechQueue: [String] = []
    private let audioSession = AVAudioSession.sharedInstance()

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    /// オーディオセッションを設定
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("オーディオセッションの設定に失敗: \(error)")
        }
    }

    /// テキストを音声で読み上げ
    func speak(_ text: String, priority: SpeechPriority = .normal) {
        guard isEnabled else { return }

        switch priority {
        case .immediate:
            // 現在の読み上げを中断して即座に読み上げ
            synthesizer.stopSpeaking(at: .immediate)
            speechQueue.removeAll()
            performSpeak(text)
        case .high:
            // 現在の読み上げ完了後に優先的に読み上げ
            speechQueue.insert(text, at: 0)
            if !synthesizer.isSpeaking {
                processQueue()
            }
        case .normal:
            // キューに追加
            speechQueue.append(text)
            if !synthesizer.isSpeaking {
                processQueue()
            }
        }
    }

    /// ナビゲーション開始のアナウンス
    func announceNavigationStart(routeInfo: RouteInfo) {
        speak(routeInfo.voiceSummary, priority: .immediate)
    }

    /// 次のステップのアナウンス
    func announceStep(_ step: NavigationStep) {
        speak(step.voiceText, priority: .high)
    }

    /// 方向転換の警告アナウンス
    func announceUpcomingTurn(distance: Int, instruction: String) {
        let text = "\(distance)メートル先、\(instruction)"
        speak(text, priority: .high)
    }

    /// 到着のアナウンス
    func announceArrival(destination: String) {
        let text = "目的地、\(destination)に到着しました。ナビゲーションを終了します。"
        speak(text, priority: .immediate)
    }

    /// 現在地の状況アナウンス
    func announceCurrentStatus(distance: String, direction: String?) {
        var text = "目的地まで残り\(distance)。"
        if let direction = direction {
            text += direction
        }
        speak(text, priority: .normal)
    }

    /// エラーのアナウンス
    func announceError(_ message: String) {
        speak("エラーが発生しました。\(message)", priority: .immediate)
    }

    /// 読み上げを停止
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        speechQueue.removeAll()
        isSpeaking = false
    }

    /// 読み上げ速度を設定
    func setSpeechRate(_ rate: Float) {
        speechRate = max(0.1, min(1.0, rate))
    }

    // MARK: - Private

    private func performSpeak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = speechRate * AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.2

        synthesizer.speak(utterance)
        isSpeaking = true
    }

    private func processQueue() {
        guard !speechQueue.isEmpty else {
            isSpeaking = false
            return
        }
        let text = speechQueue.removeFirst()
        performSpeak(text)
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension VoiceGuidanceService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.processQueue()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }
}

/// 音声読み上げの優先度
enum SpeechPriority {
    case immediate // 即座に読み上げ（現在の読み上げを中断）
    case high      // 優先的に読み上げ（キューの先頭に追加）
    case normal    // 通常の読み上げ（キューの末尾に追加）
}
