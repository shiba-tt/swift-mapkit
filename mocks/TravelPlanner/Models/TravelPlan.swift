import Foundation

/// A complete travel plan containing multiple day plans.
struct TravelPlan: Identifiable {
    let id: UUID
    let title: String
    let startDate: Date
    let dayPlans: [DayPlan]

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        dayPlans: [DayPlan]
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.dayPlans = dayPlans
    }

    var totalDays: Int { dayPlans.count }

    var totalDestinations: Int {
        dayPlans.reduce(0) { $0 + $1.destinations.count }
    }

    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        let start = formatter.string(from: startDate)
        let endDate = Calendar.current.date(
            byAdding: .day,
            value: totalDays - 1,
            to: startDate
        ) ?? startDate
        let end = formatter.string(from: endDate)
        return "\(start) 〜 \(end)"
    }
}
