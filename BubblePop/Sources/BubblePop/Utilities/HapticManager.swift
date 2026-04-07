import Foundation

struct HapticManager {
    #if os(iOS)
    static func pop() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    static func miss() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    static func combo() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    #else
    static func pop() {}
    static func miss() {}
    static func combo() {}
    #endif
}
