import SwiftUI

/// マップ上のカスタムアノテーションビュー
struct SiteAnnotationView: View {
    let site: HistoricalSite
    let isSelected: Bool
    let isFavorite: Bool

    var body: some View {
        VStack(spacing: 0) {
            // アイコンバッジ
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: isSelected ? 48 : 36, height: isSelected ? 48 : 36)
                    .shadow(color: backgroundColor.opacity(0.4), radius: isSelected ? 8 : 4)

                Image(systemName: site.category.iconName)
                    .font(.system(size: isSelected ? 20 : 14, weight: .bold))
                    .foregroundStyle(.white)

                // お気に入りバッジ
                if isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.red)
                        .offset(x: isSelected ? 18 : 14, y: isSelected ? -18 : -14)
                }
            }

            // 三角形ポインタ
            Triangle()
                .fill(backgroundColor)
                .frame(width: 12, height: 8)

            // 選択時にラベルを表示
            if isSelected {
                Text(site.name)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 2)
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }

    private var backgroundColor: Color {
        switch site.era {
        case .jomon, .yayoi, .kofun:
            return .brown
        case .asuka, .nara:
            return .orange
        case .heian:
            return .purple
        case .kamakura, .muromachi:
            return .blue
        case .azuchiMomoyama:
            return .red
        case .edo:
            return .indigo
        case .meiji, .taisho, .showa:
            return .green
        }
    }
}

// MARK: - Triangle Shape

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
