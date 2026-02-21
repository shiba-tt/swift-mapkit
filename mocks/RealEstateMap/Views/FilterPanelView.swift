import SwiftUI

/// マップのフィルタパネル
struct FilterPanelView: View {
    @Bindable var viewModel: MapViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 学区表示トグル
            HStack {
                Image(systemName: "building.columns.fill")
                    .foregroundStyle(.blue)
                Toggle("学区を表示", isOn: $viewModel.showSchoolDistricts)
            }

            if viewModel.showSchoolDistricts {
                // 学区種別フィルタ
                Picker("学区種別", selection: $viewModel.selectedSchoolLevel) {
                    Text("すべて").tag(nil as SchoolDistrict.SchoolLevel?)
                    ForEach(SchoolDistrict.SchoolLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level as SchoolDistrict.SchoolLevel?)
                    }
                }
                .pickerStyle(.segmented)

                // 凡例
                HStack(spacing: 16) {
                    Label("小学校", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Label("中学校", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Divider()

            // 駅徒歩圏トグル
            HStack {
                Image(systemName: "tram.fill")
                    .foregroundStyle(.orange)
                Toggle("駅徒歩圏を表示", isOn: $viewModel.showStationCircles)
            }

            if viewModel.showStationCircles {
                // 徒歩分数スライダー
                VStack(alignment: .leading, spacing: 4) {
                    Text("徒歩 \(viewModel.selectedWalkingMinutes)分圏")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.selectedWalkingMinutes) },
                            set: { viewModel.selectedWalkingMinutes = Int($0) }
                        ),
                        in: 5...20,
                        step: 5
                    )
                    .tint(.orange)

                    HStack {
                        Text("5分")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("10分")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("15分")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("20分")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}
