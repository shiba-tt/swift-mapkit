import SwiftUI

/// チェックイン履歴ビュー
struct CheckInHistoryView: View {
    @Environment(PilgrimageSpotStore.self) private var store

    private var totalSpots: Int {
        store.spots.count
    }

    private var visitedSpots: Int {
        Set(store.checkIns.map { $0.spotID }).count
    }

    var body: some View {
        NavigationStack {
            List {
                // 統計セクション
                statsSection

                // 履歴セクション
                if store.checkIns.isEmpty {
                    ContentUnavailableView(
                        "チェックイン履歴がありません",
                        systemImage: "clock.badge.questionmark",
                        description: Text("聖地を訪問してチェックインしましょう")
                    )
                } else {
                    historySection
                }
            }
            .navigationTitle("チェックイン履歴")
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        Section {
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    StatCard(
                        title: "訪問済み",
                        value: "\(visitedSpots)",
                        total: "/\(totalSpots)",
                        icon: "mappin.circle.fill",
                        color: .blue
                    )

                    StatCard(
                        title: "総チェックイン",
                        value: "\(store.checkIns.count)",
                        total: "回",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }

                // プログレスバー
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("巡礼達成率")
                            .font(.caption.weight(.medium))
                        Spacer()
                        Text("\(progressPercentage)%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tint)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * CGFloat(progressFraction),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var progressPercentage: Int {
        guard totalSpots > 0 else { return 0 }
        return Int(Double(visitedSpots) / Double(totalSpots) * 100)
    }

    private var progressFraction: Double {
        guard totalSpots > 0 else { return 0 }
        return Double(visitedSpots) / Double(totalSpots)
    }

    // MARK: - History

    private var historySection: some View {
        Section("履歴") {
            ForEach(store.checkIns) { checkIn in
                CheckInRowView(checkIn: checkIn)
            }
            .onDelete { offsets in
                store.deleteCheckIn(at: offsets)
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let total: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title.weight(.bold))
                Text(total)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - CheckIn Row

struct CheckInRowView: View {
    let checkIn: CheckIn

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(checkIn.spotName)
                    .font(.body.weight(.medium))
                Spacer()
                Text(checkIn.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(checkIn.workTitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            if !checkIn.note.isEmpty {
                Text(checkIn.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CheckInHistoryView()
        .environment(PilgrimageSpotStore())
}
