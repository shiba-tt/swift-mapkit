import SwiftUI

/// ナビゲーション中の情報パネル
struct NavigationPanelView: View {
    @EnvironmentObject var viewModel: NavigationViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 進捗バー
            ProgressView(value: viewModel.progressPercentage)
                .tint(.blue)
                .accessibilityLabel("ナビゲーション進捗 \(Int(viewModel.progressPercentage * 100))パーセント")

            VStack(spacing: 12) {
                // 現在のステップ表示
                if let step = viewModel.currentStep {
                    CurrentStepView(step: step)
                }

                // 残りステップ数
                HStack {
                    Text("残り \(viewModel.remainingSteps) ステップ")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if let arrival = viewModel.estimatedArrivalTime {
                        Text("到着予想: \(arrival)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)

                // コントロールボタン
                NavigationControlButtons()
            }
            .padding(16)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

/// 現在のステップ表示
struct CurrentStepView: View {
    let step: NavigationStep

    var body: some View {
        HStack(spacing: 16) {
            // 方向アイコン
            DirectionIcon(instruction: step.instruction)
                .frame(width: 50, height: 50)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(step.instruction)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(step.formattedDistance)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.voiceText)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

/// 方向を示すアイコン
struct DirectionIcon: View {
    let instruction: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)

            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.white)
        }
    }

    private var iconName: String {
        let lower = instruction.lowercased()
        if lower.contains("右") || lower.contains("right") {
            return "arrow.turn.up.right"
        } else if lower.contains("左") || lower.contains("left") {
            return "arrow.turn.up.left"
        } else if lower.contains("Uターン") || lower.contains("u-turn") {
            return "arrow.uturn.down"
        } else if lower.contains("到着") || lower.contains("destination") {
            return "mappin.circle.fill"
        } else {
            return "arrow.up"
        }
    }
}

/// ナビゲーション中のコントロールボタン
struct NavigationControlButtons: View {
    @EnvironmentObject var viewModel: NavigationViewModel

    var body: some View {
        HStack(spacing: 12) {
            // 現在位置の状況を読み上げ
            Button(action: { viewModel.announceCurrentStatus() }) {
                VStack(spacing: 4) {
                    Image(systemName: "location.circle.fill")
                        .font(.title2)
                    Text("現在地")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("現在地の状況を読み上げ")
            .accessibilityHint("目的地までの残り距離と方向を音声で案内します")

            // 現在のステップを再読み上げ
            Button(action: { viewModel.repeatCurrentStep() }) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title2)
                    Text("再読み上げ")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("案内を再読み上げ")
            .accessibilityHint("現在のナビゲーション指示をもう一度読み上げます")

            // ナビゲーション終了
            Button(action: { viewModel.stopNavigation() }) {
                VStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                    Text("終了")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .accessibilityLabel("ナビゲーション終了")
            .accessibilityHint("ナビゲーションを終了して検索画面に戻ります")
        }
    }
}

/// ルートステップ一覧ビュー
struct RouteStepsListView: View {
    @EnvironmentObject var viewModel: NavigationViewModel

    var body: some View {
        if let routeInfo = viewModel.routeInfo {
            List {
                ForEach(Array(routeInfo.steps.enumerated()), id: \.element.id) { index, step in
                    HStack(spacing: 12) {
                        // ステップ番号
                        ZStack {
                            Circle()
                                .fill(index <= viewModel.currentStepIndex ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(index <= viewModel.currentStepIndex ? .white : .gray)
                        }
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.instruction)
                                .font(.body)
                                .foregroundColor(index == viewModel.currentStepIndex ? .primary : .secondary)

                            Text(step.formattedDistance)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if index == viewModel.currentStepIndex {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                .accessibilityLabel("現在のステップ")
                        } else if index < viewModel.currentStepIndex {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .accessibilityLabel("完了済み")
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("ステップ\(index + 1)、\(step.voiceText)")
                }
            }
            .listStyle(.plain)
            .accessibilityLabel("ルートステップ一覧")
        }
    }
}
