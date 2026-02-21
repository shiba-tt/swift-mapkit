import SwiftUI

/// マップ上の写真アノテーション
struct PhotoAnnotationView: View {
    let photo: PhotoLocation
    let showOrder: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    // サムネイル画像
                    if let image = photo.thumbnailImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "photo")
                            .font(.title3)
                            .frame(width: 48, height: 48)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // 順序番号バッジ
                    if showOrder {
                        Text("\(photo.orderIndex)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(.blue, in: Capsule())
                            .offset(x: -4, y: -4)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                // 三角形ポインター
                Triangle()
                    .fill(.white)
                    .frame(width: 12, height: 6)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

/// 下向き三角形
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
