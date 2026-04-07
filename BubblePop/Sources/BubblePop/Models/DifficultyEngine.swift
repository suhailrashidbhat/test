import CoreGraphics

struct DifficultySnapshot {
    let spawnInterval: Double
    let bubbleLifetime: Double
    let maxSimultaneous: Int
    let radiusRange: ClosedRange<CGFloat>
    let pointValue: Int
}

struct DifficultyEngine {
    /// Level anchors: (level, spawnInterval, lifetime, maxBubbles, minRadius, maxRadius, points)
    private static let anchors: [(Int, Double, Double, Int, CGFloat, CGFloat, Int)] = [
        (1,  1.8, 3.5,  5, 34, 44, 1),
        (3,  1.5, 3.0,  6, 32, 43, 1),
        (5,  1.2, 2.5,  8, 30, 42, 2),
        (7,  1.0, 2.0, 10, 28, 40, 2),
        (10, 0.8, 1.8, 12, 26, 39, 3),
        (13, 0.65,1.5, 13, 24, 37, 4),
        (15, 0.5, 1.3, 15, 22, 35, 5),
    ]

    static func snapshot(level: Int) -> DifficultySnapshot {
        let clampedLevel = max(1, level)

        // Find surrounding anchors for interpolation
        var lower = anchors.first!
        var upper = anchors.last!

        for i in 0..<(anchors.count - 1) {
            if anchors[i].0 <= clampedLevel && anchors[i + 1].0 >= clampedLevel {
                lower = anchors[i]
                upper = anchors[i + 1]
                break
            }
        }

        if clampedLevel >= anchors.last!.0 {
            let a = anchors.last!
            return DifficultySnapshot(
                spawnInterval: a.1,
                bubbleLifetime: a.2,
                maxSimultaneous: a.3,
                radiusRange: a.4...a.5,
                pointValue: a.6
            )
        }

        let range = Double(upper.0 - lower.0)
        let t = range > 0 ? Double(clampedLevel - lower.0) / range : 0.0

        func lerp(_ a: Double, _ b: Double) -> Double { a + (b - a) * t }
        func lerpi(_ a: Int, _ b: Int) -> Int { Int((Double(a) + Double(b - a) * t).rounded()) }
        func lerpf(_ a: CGFloat, _ b: CGFloat) -> CGFloat { a + (b - a) * CGFloat(t) }

        return DifficultySnapshot(
            spawnInterval: lerp(lower.1, upper.1),
            bubbleLifetime: lerp(lower.2, upper.2),
            maxSimultaneous: lerpi(lower.3, upper.3),
            radiusRange: lerpf(lower.4, upper.4)...lerpf(lower.5, upper.5),
            pointValue: lerpi(lower.6, upper.6)
        )
    }
}
