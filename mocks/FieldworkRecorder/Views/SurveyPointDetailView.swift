import SwiftUI
import MapKit
import PhotosUI

struct SurveyPointDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: FieldworkViewModel
    @Bindable var point: SurveyPoint

    @State private var isEditing = false
    @State private var editTitle: String = ""
    @State private var editNote: String = ""
    @State private var editCategory: String = ""
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // Location section
                Section("位置情報") {
                    Map(position: .constant(.region(
                        MKCoordinateRegion(
                            center: point.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                        )
                    ))) {
                        Annotation(point.title, coordinate: point.coordinate) {
                            SurveyPointMarker(point: point)
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    LabeledContent("緯度", value: String(format: "%.6f", point.latitude))
                    LabeledContent("経度", value: String(format: "%.6f", point.longitude))
                    LabeledContent("記録日時") {
                        Text(point.createdAt, style: .date)
                        Text(point.createdAt, style: .time)
                    }
                }

                // Category section
                Section("カテゴリ") {
                    if isEditing {
                        Picker("カテゴリ", selection: $editCategory) {
                            ForEach(Array(SurveyPoint.categories.keys.sorted()), id: \.self) { key in
                                Label(categoryDisplayName(key), systemImage: SurveyPoint.categories[key] ?? "mappin")
                                    .tag(key)
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        Label(categoryDisplayName(point.category), systemImage: point.categoryIcon)
                    }
                }

                // Note section
                Section("メモ") {
                    if isEditing {
                        TextField("タイトル", text: $editTitle)
                        TextEditor(text: $editNote)
                            .frame(minHeight: 100)
                    } else {
                        if !point.title.isEmpty {
                            Text(point.title)
                                .font(.headline)
                        }
                        if point.note.isEmpty {
                            Text("メモなし")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(point.note)
                        }
                    }
                }

                // Photos section
                Section("写真") {
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("写真を追加", systemImage: "photo.badge.plus")
                    }
                    .onChange(of: selectedPhotoItems) { _, newItems in
                        Task {
                            await loadPhotos(from: newItems)
                        }
                    }

                    if !point.photoFileNames.isEmpty {
                        PhotoGridView(
                            fileNames: point.photoFileNames,
                            viewModel: viewModel,
                            onDelete: { fileName in
                                viewModel.deletePhoto(fileName: fileName, from: point)
                            }
                        )
                    } else {
                        Text("写真なし")
                            .foregroundStyle(.secondary)
                    }
                }

                // Delete section
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("この地点を削除", systemImage: "trash")
                    }
                }
            }
            .navigationTitle(point.title.isEmpty ? "調査地点" : point.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "保存" : "編集") {
                        if isEditing {
                            point.title = editTitle
                            point.note = editNote
                            point.category = editCategory
                        } else {
                            editTitle = point.title
                            editNote = point.note
                            editCategory = point.category
                        }
                        isEditing.toggle()
                    }
                }
            }
            .confirmationDialog("この地点を削除しますか？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("削除", role: .destructive) {
                    viewModel.deletePoint(point, modelContext: modelContext)
                    dismiss()
                }
                Button("キャンセル", role: .cancel) {}
            }
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                _ = viewModel.savePhoto(data: data, for: point)
            }
        }
        selectedPhotoItems = []
    }

    private func categoryDisplayName(_ key: String) -> String {
        switch key {
        case "default": "デフォルト"
        case "flora": "植物"
        case "fauna": "動物"
        case "geology": "地質"
        case "water": "水域"
        case "structure": "構造物"
        default: key
        }
    }
}

// MARK: - Photo Grid

struct PhotoGridView: View {
    let fileNames: [String]
    let viewModel: FieldworkViewModel
    let onDelete: (String) -> Void

    @State private var selectedPhoto: String?

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(fileNames, id: \.self) { fileName in
                PhotoThumbnail(url: viewModel.photoURL(for: fileName))
                    .onTapGesture { selectedPhoto = fileName }
                    .contextMenu {
                        Button(role: .destructive) {
                            onDelete(fileName)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
            }
        }
        .padding(.vertical, 4)
        .fullScreenCover(item: $selectedPhoto) { fileName in
            PhotoFullScreenView(
                url: viewModel.photoURL(for: fileName),
                onDismiss: { selectedPhoto = nil }
            )
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Photo Thumbnail

struct PhotoThumbnail: View {
    let url: URL

    var body: some View {
        AsyncImageFileView(url: url)
            .aspectRatio(1, contentMode: .fill)
            .frame(minWidth: 80, minHeight: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct AsyncImageFileView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .task {
            image = UIImage(contentsOfFile: url.path)
        }
    }
}

// MARK: - Full Screen Photo

struct PhotoFullScreenView: View {
    let url: URL
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            AsyncImageFileView(url: url)
                .scaledToFit()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
    }
}
