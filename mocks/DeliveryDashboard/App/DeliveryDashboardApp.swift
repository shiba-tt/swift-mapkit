import SwiftUI

@main
struct DeliveryDashboardApp: App {
    @StateObject private var deliveryManager = DeliveryManager()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(deliveryManager)
        }
    }
}
