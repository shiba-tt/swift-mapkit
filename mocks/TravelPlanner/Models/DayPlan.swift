import Foundation
import SwiftUI

/// A single day's plan containing multiple destinations.
struct DayPlan: Identifiable {
    let id: UUID
    let dayNumber: Int
    let title: String
    let destinations: [Destination]
    let color: Color

    init(
        id: UUID = UUID(),
        dayNumber: Int,
        title: String,
        destinations: [Destination],
        color: Color
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.title = title
        self.destinations = destinations
        self.color = color
    }

    /// Predefined colors for day-based route coloring.
    static let dayColors: [Color] = [
        .blue,
        .orange,
        .green,
        .purple,
        .red,
        .cyan,
        .pink,
        .yellow,
        .mint,
        .indigo
    ]

    static func colorForDay(_ day: Int) -> Color {
        dayColors[(day - 1) % dayColors.count]
    }
}
