import SwiftUI

/// Main entry point for the Travel Planner app.
@main
struct TravelPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Root content view with navigation.
struct ContentView: View {
    @State private var selectedPlanID: UUID?
    private let plans = SampleData.allPlans

    var body: some View {
        NavigationStack {
            TravelPlanListView(plans: plans)
                .navigationDestination(for: UUID.self) { planID in
                    if let plan = plans.first(where: { $0.id == planID }) {
                        TravelPlanDetailView(plan: plan)
                    }
                }
        }
    }
}
