import SwiftUI

/// List view showing all available travel plans.
struct TravelPlanListView: View {
    let plans: [TravelPlan]

    var body: some View {
        List(plans) { plan in
            NavigationLink(value: plan.id) {
                TravelPlanCardView(plan: plan)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
        .listStyle(.plain)
        .navigationTitle("旅行プラン")
    }
}

/// Card view for a single travel plan in the list.
struct TravelPlanCardView: View {
    let plan: TravelPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.title)
                .font(.headline)

            Text(plan.dateRangeText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Label("\(plan.totalDays)日間", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label("\(plan.totalDestinations)箇所", systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Day color legend
            HStack(spacing: 6) {
                ForEach(plan.dayPlans) { day in
                    HStack(spacing: 3) {
                        Circle()
                            .fill(day.color)
                            .frame(width: 8, height: 8)
                        Text("Day\(day.dayNumber)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
