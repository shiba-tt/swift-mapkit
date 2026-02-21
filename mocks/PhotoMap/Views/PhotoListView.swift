import SwiftUI

/// 撮影順に写真を一覧表示するリスト
struct PhotoListView: View {
    @ObservedObject var viewModel: PhotoMapViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.photos.isEmpty {
                    ContentUnavailableView(
                        "写真がありません",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("GPS情報付きの写真が見つかりませんでした")
                    )
                } else {
                    List(viewModel.photos) { photo in
                        Button {
                            dismiss()
                            viewModel.focusOnPhoto(photo)
                        } label: {
                            photoRow(photo)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("写真一覧（\(viewModel.photos.count)枚）")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func photoRow(_ photo: PhotoLocation) -> some View {
        HStack(spacing: 12) {
            // 順序番号
            Text("\(photo.orderIndex)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.blue, in: Circle())

            // サムネイル
            if let image = photo.thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Image(systemName: "photo")
                    .frame(width: 50, height: 50)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            // 情報
            VStack(alignment: .leading, spacing: 4) {
                Text(photo.timestamp, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text(photo.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    String(
                        format: "%.4f, %.4f",
                        photo.coordinate.latitude,
                        photo.coordinate.longitude
                    )
                )
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(.blue)
        }
    }
}
