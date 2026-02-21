import SwiftUI
import MapKit

/// Look Aroundプレビュー表示
struct LookAroundPreviewView: View {
    let scene: MKLookAroundScene?
    let propertyName: String
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let scene {
                    LookAroundPreview(initialScene: scene)
                        .ignoresSafeArea(.all, edges: .bottom)
                } else {
                    ContentUnavailableView(
                        "Look Around 利用不可",
                        systemImage: "binoculars.slash",
                        description: Text("この場所ではLook Aroundを利用できません")
                    )
                }
            }
            .navigationTitle(propertyName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        onDismiss()
                    }
                }
            }
        }
    }
}
