import SwiftUI

struct Bubble: Identifiable {
    let id: UUID
    let position: CGPoint
    let color: Color
    let radius: CGFloat
    let lifetime: Double
    let spawnTime: Date
    var isPopped: Bool = false

    /// 0.0 = just spawned, 1.0 = expired
    var progress: Double {
        min(Date().timeIntervalSince(spawnTime) / lifetime, 1.0)
    }

    /// Ring stroke color shifts from bubble color → yellow → red as urgency increases
    var ringColor: Color {
        if progress < 0.5 { return color.opacity(0.8) }
        if progress < 0.8 { return .yellow }
        return .red
    }

    static let palette: [Color] = [
        Color(red: 1.0, green: 0.27, blue: 0.27),   // coral red
        Color(red: 1.0, green: 0.60, blue: 0.10),   // vivid orange
        Color(red: 1.0, green: 0.88, blue: 0.10),   // bright yellow
        Color(red: 0.20, green: 0.90, blue: 0.40),  // spring green
        Color(red: 0.10, green: 0.75, blue: 1.00),  // sky blue
        Color(red: 0.75, green: 0.35, blue: 1.00),  // violet
    ]
}
