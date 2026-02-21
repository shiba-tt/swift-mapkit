import SwiftUI

extension Color {
    static let gameBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.2)
    static let neutralZone = Color.gray.opacity(0.5)

    func withBrightness(_ factor: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0, saturation: CGFloat = 0
        var brightness: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(hue: Double(hue), saturation: Double(saturation),
                     brightness: Double(brightness) * factor, opacity: Double(alpha))
    }
}

extension Team {
    var mapOverlayColor: UIColor {
        uiColor.withAlphaComponent(0.3)
    }

    var mapStrokeColor: UIColor {
        uiColor.withAlphaComponent(0.8)
    }
}
