import SwiftUI

/// マップ上の投稿マーカー
struct PostAnnotationView: View {
    let post: Post

    var body: some View {
        VStack(spacing: 0) {
            // バブル部分
            HStack(spacing: 4) {
                Image(systemName: post.category.icon)
                    .font(.caption2)

                if post.likeCount > 0 {
                    Text("\(post.likeCount)")
                        .font(.system(size: 9, weight: .bold))
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(post.category.color, in: Capsule())
            .foregroundStyle(.white)
            .overlay(
                Capsule()
                    .stroke(.white, lineWidth: 1.5)
            )
            .shadow(color: post.category.color.opacity(0.4), radius: 4, y: 2)

            // 矢印部分
            Triangle()
                .fill(post.category.color)
                .frame(width: 10, height: 6)
                .shadow(color: post.category.color.opacity(0.3), radius: 2, y: 1)
        }
        .opacity(post.isResolved ? 0.6 : 1.0)
    }
}

/// 吹き出しの矢印
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
