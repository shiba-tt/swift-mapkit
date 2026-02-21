import SwiftUI

struct LegendView: View {
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ヘッダー
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.caption)
                    Text("凡例")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }

            if isExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    // 危険レベル
                    Text("危険レベル")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    ForEach(DangerLevel.allCases) { level in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(level.color.opacity(level == .safe ? 0.3 : level.opacity + 0.2))
                                .frame(width: 14, height: 14)
                            Text(level.label)
                                .font(.caption)
                        }
                    }

                    Divider()

                    // 犯罪深刻度
                    Text("犯罪深刻度")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    ForEach(CrimeIncident.Severity.allCases, id: \.rawValue) { severity in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(severity.color)
                                .frame(width: 14, height: 14)
                            Text(severity.label)
                                .font(.caption)
                        }
                    }

                    Divider()

                    // カメラ種別
                    Text("防犯カメラ")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    ForEach(CameraType.allCases) { type in
                        HStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.caption)
                                .foregroundStyle(type.color)
                                .frame(width: 14)
                            Text(type.rawValue)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .frame(width: isExpanded ? 150 : 80)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        LegendView(isExpanded: .constant(true))
    }
}
