import SwiftUI

/// 距離圏リングの設定ビュー
struct DistanceRingSettingsView: View {
    @Bindable var viewModel: TradeAreaViewModel

    @State private var newRingRadius: Double = 2000
    @State private var newRingColor: Color = .teal

    @Environment(\.dismiss) private var dismiss

    /// プリセット距離（メートル）
    private let presetDistances: [(label: String, meters: Double)] = [
        ("300m", 300),
        ("500m", 500),
        ("1km", 1000),
        ("2km", 2000),
        ("3km", 3000),
        ("5km", 5000),
        ("10km", 10000),
    ]

    var body: some View {
        NavigationStack {
            List {
                // 現在のリング一覧
                currentRingsSection

                // リング追加
                addRingSection

                // プリセット
                presetSection

                // 検索範囲設定
                searchRadiusSection
            }
            .navigationTitle("距離圏設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }

    // MARK: - 現在のリング一覧

    private var currentRingsSection: some View {
        Section {
            if viewModel.config.rings.isEmpty {
                Text("距離圏が設定されていません")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.config.rings) { ring in
                    HStack {
                        Circle()
                            .fill(ring.color)
                            .frame(width: 16, height: 16)

                        Text(ring.formattedRadius)
                            .font(.body)

                        Spacer()

                        // 表示/非表示トグル
                        Button {
                            viewModel.toggleRing(ring)
                        } label: {
                            Image(systemName: ring.isVisible ? "eye.fill" : "eye.slash")
                                .foregroundStyle(ring.isVisible ? .blue : .secondary)
                        }
                        .buttonStyle(.plain)

                        // 削除
                        Button(role: .destructive) {
                            viewModel.removeRing(ring)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        } header: {
            Text("現在の距離圏")
        }
    }

    // MARK: - リング追加

    private var addRingSection: some View {
        Section {
            VStack(spacing: 12) {
                HStack {
                    Text("半径")
                    Spacer()
                    Text(formatRadius(newRingRadius))
                        .foregroundStyle(.secondary)
                }

                Slider(value: $newRingRadius, in: 100...10000, step: 100)
                    .tint(.blue)

                ColorPicker("リングの色", selection: $newRingColor)

                Button {
                    viewModel.addRing(radius: newRingRadius, color: newRingColor)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("距離圏を追加")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        } header: {
            Text("カスタム追加")
        }
    }

    // MARK: - プリセット

    private var presetSection: some View {
        Section {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ],
                spacing: 8
            ) {
                ForEach(presetDistances, id: \.meters) { preset in
                    let exists = viewModel.config.rings.contains { $0.radius == preset.meters }

                    Button {
                        if !exists {
                            viewModel.addRing(radius: preset.meters, color: colorForDistance(preset.meters))
                        }
                    } label: {
                        Text(preset.label)
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                exists ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1),
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .foregroundStyle(exists ? .secondary : .blue)
                    }
                    .buttonStyle(.plain)
                    .disabled(exists)
                }
            }
        } header: {
            Text("プリセット")
        }
    }

    // MARK: - 検索範囲設定

    private var searchRadiusSection: some View {
        Section {
            VStack(spacing: 8) {
                HStack {
                    Text("検索半径")
                    Spacer()
                    Text(formatRadius(viewModel.config.searchRadius))
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: $viewModel.config.searchRadius,
                    in: 500...10000,
                    step: 500
                )
                .tint(.orange)

                Button {
                    viewModel.updateSearchRadius()
                } label: {
                    Text("最大距離圏に合わせる")
                        .font(.subheadline)
                }
            }
        } header: {
            Text("検索範囲")
        } footer: {
            Text("競合検索の最大半径を設定します。大きいほど広範囲を検索しますが、結果が多くなります。")
        }
    }

    // MARK: - Helpers

    private func formatRadius(_ radius: Double) -> String {
        if radius >= 1000 {
            return String(format: "%.1f km", radius / 1000)
        }
        return String(format: "%.0f m", radius)
    }

    private func colorForDistance(_ meters: Double) -> Color {
        switch meters {
        case ...500: return .green
        case ...1000: return .yellow.opacity(0.9)
        case ...3000: return .orange
        case ...5000: return .red.opacity(0.8)
        default: return .purple
        }
    }
}
