import SwiftUI
import SwiftData

@main
struct FieldworkRecorderApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SurveyPoint.self,
            AreaBoundary.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("ModelContainer を作成できませんでした: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
