import SwiftUI
import MapKit

/// 新規投稿作成ビュー
struct CreatePostView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var body = ""
    @State private var category: PostCategory = .info
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var hasExpiry = false
    @State private var expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!

    @State private var postCoordinate: CLLocationCoordinate2D
    @State private var mapPosition: MapCameraPosition

    init(viewModel: MapViewModel, locationManager: LocationManager) {
        self.viewModel = viewModel
        self.locationManager = locationManager

        let coordinate = viewModel.newPostCoordinate
            ?? locationManager.userLocation
            ?? CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)

        _postCoordinate = State(initialValue: coordinate)
        _mapPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        ))
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !body.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // カテゴリ選択
                Section("カテゴリ") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(PostCategory.allCases) { cat in
                            categoryButton(cat)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 投稿内容
                Section("投稿内容") {
                    TextField("タイトル", text: $title)
                    TextField("詳しい内容を入力...", text: $body, axis: .vertical)
                        .lineLimit(4...8)
                }

                // タグ
                Section("タグ") {
                    HStack {
                        TextField("タグを追加", text: $tagInput)
                            .onSubmit { addTag() }
                        Button("追加") { addTag() }
                            .disabled(tagInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack(spacing: 2) {
                                        Text("#\(tag)")
                                            .font(.caption)
                                        Button {
                                            tags.removeAll { $0 == tag }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption2)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(category.color.opacity(0.1), in: Capsule())
                                    .foregroundStyle(category.color)
                                }
                            }
                        }
                    }
                }

                // 有効期限
                Section("有効期限") {
                    Toggle("有効期限を設定", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("期限", selection: $expiryDate, in: Date()..., displayedComponents: [.date])
                    }
                }

                // 位置情報
                Section("投稿場所") {
                    Map(position: $mapPosition, interactionModes: [.pan, .zoom]) {
                        Annotation("投稿場所", coordinate: postCoordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(category.color)
                                .background(Circle().fill(.white).frame(width: 24, height: 24))
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                    Text("座標: \(postCoordinate.latitude, specifier: "%.4f"), \(postCoordinate.longitude, specifier: "%.4f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("新しい投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        viewModel.newPostCoordinate = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("投稿する") {
                        submitPost()
                    }
                    .bold()
                    .disabled(!isValid)
                }
            }
        }
    }

    private func categoryButton(_ cat: PostCategory) -> some View {
        VStack(spacing: 4) {
            Image(systemName: cat.icon)
                .font(.title3)
            Text(cat.rawValue)
                .font(.system(size: 9))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            category == cat ? cat.color.opacity(0.2) : Color.gray.opacity(0.05),
            in: RoundedRectangle(cornerRadius: 8)
        )
        .foregroundStyle(category == cat ? cat.color : .secondary)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(category == cat ? cat.color : Color.clear, lineWidth: 1.5)
        )
        .onTapGesture {
            withAnimation { category = cat }
        }
    }

    private func addTag() {
        let tag = tagInput.trimmingCharacters(in: .whitespaces)
        guard !tag.isEmpty, !tags.contains(tag) else { return }
        tags.append(tag)
        tagInput = ""
    }

    private func submitPost() {
        viewModel.createPost(
            title: title.trimmingCharacters(in: .whitespaces),
            body: body.trimmingCharacters(in: .whitespaces),
            category: category,
            tags: tags,
            coordinate: postCoordinate
        )
        dismiss()
    }
}
