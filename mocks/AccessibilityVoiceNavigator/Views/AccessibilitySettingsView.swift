import SwiftUI

/// アクセシビリティ設定ビュー
struct AccessibilitySettingsView: View {
    @EnvironmentObject var viewModel: NavigationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // 音声ガイダンス設定
                Section {
                    Toggle("音声ガイダンス", isOn: $viewModel.voiceGuidanceService.isEnabled)
                        .accessibilityLabel("音声ガイダンスの有効・無効")
                        .accessibilityHint(
                            viewModel.voiceGuidanceService.isEnabled
                                ? "現在有効です。無効にするにはダブルタップしてください"
                                : "現在無効です。有効にするにはダブルタップしてください"
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("読み上げ速度")
                            .font(.body)

                        HStack {
                            Text("遅い")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Slider(
                                value: $viewModel.voiceGuidanceService.speechRate,
                                in: 0.1...1.0,
                                step: 0.1
                            )
                            .accessibilityLabel("読み上げ速度")
                            .accessibilityValue("速度 \(Int(viewModel.voiceGuidanceService.speechRate * 100))パーセント")

                            Text("速い")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("音声設定")
                        .accessibilityAddTraits(.isHeader)
                }

                // 使い方ガイド
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        AccessibilityGuideRow(
                            icon: "magnifyingglass",
                            title: "目的地検索",
                            description: "検索欄に目的地の名前や住所を入力して検索ボタンをタップ"
                        )
                        AccessibilityGuideRow(
                            icon: "hand.tap",
                            title: "目的地選択",
                            description: "検索結果から目的地をダブルタップで選択"
                        )
                        AccessibilityGuideRow(
                            icon: "location.fill",
                            title: "ナビ開始",
                            description: "経路確認後、ナビ開始ボタンをダブルタップ"
                        )
                        AccessibilityGuideRow(
                            icon: "speaker.wave.3.fill",
                            title: "音声案内",
                            description: "各ステップで自動的に音声ガイダンスが流れます"
                        )
                        AccessibilityGuideRow(
                            icon: "arrow.counterclockwise",
                            title: "再読み上げ",
                            description: "再読み上げボタンで現在の案内をもう一度聞けます"
                        )
                    }
                } header: {
                    Text("使い方")
                        .accessibilityAddTraits(.isHeader)
                }

                // VoiceOver向けジェスチャーガイド
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1本指で右スワイプ：次の要素に移動")
                        Text("1本指で左スワイプ：前の要素に移動")
                        Text("ダブルタップ：要素を選択")
                        Text("3本指で上スワイプ：スクロール")
                    }
                    .font(.body)
                    .foregroundColor(.primary)
                } header: {
                    Text("VoiceOverジェスチャー")
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .accessibilityLabel("設定を閉じる")
                }
            }
        }
    }
}

/// 使い方ガイドの行
struct AccessibilityGuideRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)。\(description)")
    }
}
