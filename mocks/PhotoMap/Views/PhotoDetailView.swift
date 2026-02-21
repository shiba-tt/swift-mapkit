import SwiftUI
import MapKit

/// 写真の詳細表示シート
struct PhotoDetailView: View {
    let photo: PhotoLocation
    @State private var fullImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    imageSection
                    infoSection
                    miniMapSection
                }
                .padding()
            }
            .navigationTitle("写真の詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .task {
                fullImage = await PhotoLibraryService.fetchFullImage(
                    for: photo.assetLocalIdentifier
                )
            }
        }
    }

    // MARK: - Subviews

    private var imageSection: some View {
        Group {
            if let image = fullImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let thumb = photo.thumbnailImage {
                Image(uiImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .aspectRatio(4 / 3, contentMode: .fit)
                    .overlay {
                        ProgressView()
                    }
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("撮影順: \(photo.orderIndex)枚目")
            } icon: {
                Image(systemName: "number")
            }

            Label {
                Text(photo.timestamp, style: .date)
                + Text("  ")
                + Text(photo.timestamp, style: .time)
            } icon: {
                Image(systemName: "calendar")
            }

            Label {
                Text(
                    String(
                        format: "%.6f, %.6f",
                        photo.coordinate.latitude,
                        photo.coordinate.longitude
                    )
                )
                .textSelection(.enabled)
            } icon: {
                Image(systemName: "location")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var miniMapSection: some View {
        Map(initialPosition: .region(
            MKCoordinateRegion(
                center: photo.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        )) {
            Marker("撮影場所", coordinate: photo.coordinate)
        }
        .mapStyle(.standard)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }
}
