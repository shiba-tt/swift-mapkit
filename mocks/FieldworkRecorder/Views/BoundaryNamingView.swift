import SwiftUI

struct BoundaryNamingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: FieldworkViewModel

    @State private var name = ""
    @State private var note = ""
    @State private var colorHex = "#FF6B6B"

    private let colorOptions = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
        "#FFEAA7", "#DDA0DD", "#FF8C42", "#98D8C8"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("エリア情報") {
                    TextField("エリア名", text: $name)
                    LabeledContent("頂点数", value: "\(viewModel.boundaryVertices.count)")
                }

                Section("カラー") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 8) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if hex == colorHex {
                                        Image(systemName: "checkmark")
                                            .font(.headline.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture { colorHex = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("メモ") {
                    TextEditor(text: $note)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("エリア境界の保存")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.showBoundaryNaming = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.finishBoundaryDrawing(
                            name: name,
                            note: note,
                            modelContext: modelContext
                        )
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
