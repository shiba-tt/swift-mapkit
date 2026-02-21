import SwiftUI

struct FilterPanelView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        NavigationStack {
            Form {
                // 表示切替
                Section("表示項目") {
                    Toggle(isOn: $viewModel.showCrimes) {
                        Label("犯罪発生情報", systemImage: "exclamationmark.triangle.fill")
                    }
                    .tint(.red)

                    Toggle(isOn: $viewModel.showCameras) {
                        Label("防犯カメラ", systemImage: "video.fill")
                    }
                    .tint(.blue)

                    Toggle(isOn: $viewModel.showDangerZones) {
                        Label("危険エリア", systemImage: "circle.dashed")
                    }
                    .tint(.orange)

                    Toggle(isOn: $viewModel.showResolvedCrimes) {
                        Label("解決済み事件も表示", systemImage: "checkmark.circle")
                    }
                    .tint(.green)
                }

                // 犯罪種別フィルター
                if viewModel.showCrimes {
                    Section("犯罪種別") {
                        ForEach(CrimeType.allCases) { type in
                            Button {
                                toggleCrimeType(type)
                            } label: {
                                HStack {
                                    Image(systemName: type.icon)
                                        .foregroundStyle(type.color)
                                        .frame(width: 24)
                                    Text(type.rawValue)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if viewModel.selectedCrimeTypes.contains(type) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }

                    Section("犯罪深刻度（最小レベル）") {
                        Picker("最小深刻度", selection: $viewModel.minimumSeverity) {
                            ForEach(CrimeIncident.Severity.allCases, id: \.rawValue) { severity in
                                HStack {
                                    Circle()
                                        .fill(severity.color)
                                        .frame(width: 10, height: 10)
                                    Text(severity.label)
                                }
                                .tag(severity)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // カメラ種別フィルター
                if viewModel.showCameras {
                    Section("カメラ種別") {
                        ForEach(CameraType.allCases) { type in
                            Button {
                                toggleCameraType(type)
                            } label: {
                                HStack {
                                    Image(systemName: type.icon)
                                        .foregroundStyle(type.color)
                                        .frame(width: 24)
                                    Text(type.rawValue)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if viewModel.selectedCameraTypes.contains(type) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                }

                // 危険レベルフィルター
                if viewModel.showDangerZones {
                    Section("表示する危険レベル（最小）") {
                        Picker("最小危険レベル", selection: $viewModel.minimumDangerLevel) {
                            ForEach(DangerLevel.allCases) { level in
                                HStack {
                                    Circle()
                                        .fill(level.color)
                                        .frame(width: 10, height: 10)
                                    Text(level.label)
                                }
                                .tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // リセット
                Section {
                    Button("フィルターをリセット", role: .destructive) {
                        withAnimation {
                            viewModel.resetFilters()
                        }
                    }
                }
            }
            .navigationTitle("フィルター設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        viewModel.showingFilter = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func toggleCrimeType(_ type: CrimeType) {
        if viewModel.selectedCrimeTypes.contains(type) {
            viewModel.selectedCrimeTypes.remove(type)
        } else {
            viewModel.selectedCrimeTypes.insert(type)
        }
    }

    private func toggleCameraType(_ type: CameraType) {
        if viewModel.selectedCameraTypes.contains(type) {
            viewModel.selectedCameraTypes.remove(type)
        } else {
            viewModel.selectedCameraTypes.insert(type)
        }
    }
}

#Preview {
    FilterPanelView(viewModel: MapViewModel())
}
