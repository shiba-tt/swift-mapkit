import SwiftUI
import MapKit

/// A sheet view presenting Look Around street-level imagery for a destination.
struct LookAroundPreviewSheet: View {
    let destination: Destination
    let scene: MKLookAroundScene
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with destination info
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: destination.category.systemImage)
                            .foregroundStyle(.secondary)
                        Text(destination.name)
                            .font(.headline)
                    }
                    Text("Look Aroundで事前確認")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()

                // Look Around viewer
                LookAroundPreview(initialScene: scene)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Look Around")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}
