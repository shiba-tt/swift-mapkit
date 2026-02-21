import SwiftUI
import CoreLocation

struct NewPointEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: FieldworkViewModel

    @State private var title = ""
    @State private var note = ""
    @State private var category = "default"

    var body: some View {
        NavigationStack {
            Form {
                Section("地点情報") {
                    TextField("タイトル", text: $title)
                    if let coord = viewModel.pendingPointCoordinate {
                        LabeledContent("緯度", value: String(format: "%.6f", coord.latitude))
                        LabeledContent("経度", value: String(format: "%.6f", coord.longitude))
                    }
                }

                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $category) {
                        Label("デフォルト", systemImage: "mappin").tag("default")
                        Label("植物", systemImage: "leaf.fill").tag("flora")
                        Label("動物", systemImage: "pawprint.fill").tag("fauna")
                        Label("地質", systemImage: "mountain.2.fill").tag("geology")
                        Label("水域", systemImage: "drop.fill").tag("water")
                        Label("構造物", systemImage: "building.2.fill").tag("structure")
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("メモ") {
                    TextEditor(text: $note)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("新しい調査地点")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.pendingPointCoordinate = nil
                        viewModel.showNewPointEditor = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        viewModel.addSurveyPoint(
                            title: title,
                            note: note,
                            category: category,
                            modelContext: modelContext
                        )
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
