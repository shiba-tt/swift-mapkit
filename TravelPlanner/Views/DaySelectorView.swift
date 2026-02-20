import SwiftUI

/// Horizontal scrollable day selector for switching between day plans.
struct DaySelectorView: View {
    let dayPlans: [DayPlan]
    @Binding var selectedDay: DayPlan?
    let showAllDays: Bool
    var onShowAllDays: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All days" button
                Button {
                    onShowAllDays()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.caption)
                        Text("全日程")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        showAllDays
                            ? AnyShapeStyle(.tint)
                            : AnyShapeStyle(.quaternary)
                    )
                    .foregroundStyle(showAllDays ? .white : .primary)
                    .clipShape(Capsule())
                }

                // Individual day buttons
                ForEach(dayPlans) { day in
                    Button {
                        selectedDay = day
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(day.color)
                                .frame(width: 8, height: 8)
                            Text("Day \(day.dayNumber)")
                                .font(.caption.bold())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            selectedDay?.id == day.id && !showAllDays
                                ? AnyShapeStyle(day.color)
                                : AnyShapeStyle(.quaternary)
                        )
                        .foregroundStyle(
                            selectedDay?.id == day.id && !showAllDays ? .white : .primary
                        )
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
