import SwiftUI
import Combine

// MARK: - Game Phase

enum GamePhase: Equatable {
    case menu
    case playing
    case paused
    case gameOver
}

// MARK: - Score Popup

struct ScorePopup: Identifiable {
    let id = UUID()
    let value: Int
    let position: CGPoint
}

// MARK: - GameState

class GameState: ObservableObject {

    // Published game state
    @Published var phase: GamePhase = .menu
    @Published var bubbles: [Bubble] = []
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var level: Int = 1
    @Published var highScore: Int = 0
    @Published var combo: Int = 0
    @Published var showComboFlash: Bool = false
    @Published var comboMultiplier: Int = 1
    @Published var tick: Int = 0                      // heartbeat for bubble progress redraws
    @Published var scorePopups: [ScorePopup] = []
    @Published var showMissFlash: Bool = false
    @Published var shakeScreen: Bool = false
    @Published var gameSize: CGSize = .zero

    // Timers
    private var spawnTimer: Timer?
    private var tickTimer: Timer?
    private var startTime: Date = Date()

    // Elapsed time tracking
    private var elapsedTime: Double = 0
    private var lastTickTime: Date = Date()

    private let highScoreKey = "BubblePop.highScore"

    init() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }

    // MARK: - Public Interface

    func setGameSize(_ size: CGSize) {
        gameSize = size
    }

    func startGame() {
        invalidateTimers()
        bubbles = []
        score = 0
        lives = 3
        level = 1
        combo = 0
        comboMultiplier = 1
        showComboFlash = false
        scorePopups = []
        elapsedTime = 0
        startTime = Date()
        lastTickTime = Date()
        phase = .playing

        scheduleSpawnTimer()
        scheduleTickTimer()
    }

    func pauseGame() {
        guard phase == .playing else { return }
        phase = .paused
        invalidateTimers()
    }

    func resumeGame() {
        guard phase == .paused else { return }
        phase = .playing
        lastTickTime = Date()
        scheduleSpawnTimer()
        scheduleTickTimer()
    }

    func endGame() {
        phase = .gameOver
        invalidateTimers()
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }
    }

    func tapBubble(id: UUID) {
        guard let idx = bubbles.firstIndex(where: { $0.id == id && !$0.isPopped }) else { return }

        bubbles[idx].isPopped = true
        combo += 1
        comboMultiplier = min(combo / 5 + 1, 4)

        let snapshot = DifficultyEngine.snapshot(level: level)
        let points = snapshot.pointValue * comboMultiplier
        score += points

        // Score popup
        let popup = ScorePopup(value: points, position: bubbles[idx].position)
        scorePopups.append(popup)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.scorePopups.removeAll { $0.id == popup.id }
        }

        // Haptics
        if combo % 5 == 0 && combo > 0 {
            HapticManager.combo()
            showComboFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
                self?.showComboFlash = false
            }
        } else {
            HapticManager.pop()
        }

        // Defer removal to allow pop animation to complete
        let bubbleID = bubbles[idx].id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.bubbles.removeAll { $0.id == bubbleID }
        }
    }

    // MARK: - Timers

    private func scheduleSpawnTimer() {
        let snapshot = DifficultyEngine.snapshot(level: level)
        spawnTimer = Timer.scheduledTimer(withTimeInterval: snapshot.spawnInterval, repeats: true) { [weak self] _ in
            self?.spawnBubble()
        }
    }

    private func scheduleTickTimer() {
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func invalidateTimers() {
        spawnTimer?.invalidate()
        spawnTimer = nil
        tickTimer?.invalidate()
        tickTimer = nil
    }

    // MARK: - Tick (heartbeat)

    private func tick() {
        let now = Date()
        let dt = now.timeIntervalSince(lastTickTime)
        lastTickTime = now
        elapsedTime += dt

        // Advance level every 10 seconds
        let newLevel = Int(elapsedTime / 10.0) + 1
        if newLevel != level {
            level = newLevel
            // Reschedule spawn timer with new interval
            spawnTimer?.invalidate()
            scheduleSpawnTimer()
        }

        // Check for expired bubbles
        let expired = bubbles.filter { !$0.isPopped && $0.progress >= 1.0 }
        for _ in expired {
            lives -= 1
            combo = 0
            comboMultiplier = 1
            HapticManager.miss()

            // Miss flash + shake
            showMissFlash = true
            shakeScreen = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.showMissFlash = false
                self?.shakeScreen = false
            }
        }
        bubbles.removeAll { !$0.isPopped && $0.progress >= 1.0 }

        if lives <= 0 {
            endGame()
            return
        }

        tick += 1  // drives BubbleView re-renders for progress ring
    }

    // MARK: - Spawn

    private func spawnBubble() {
        guard phase == .playing else { return }
        let snapshot = DifficultyEngine.snapshot(level: level)
        guard bubbles.count < snapshot.maxSimultaneous else { return }
        guard gameSize != .zero else { return }

        let radius = CGFloat.random(in: snapshot.radiusRange)
        let position = randomPosition(radius: radius, existingBubbles: bubbles, gameSize: gameSize)
        let color = Bubble.palette.randomElement()!
        let lifetime = snapshot.bubbleLifetime + Double.random(in: -0.2...0.2)

        let bubble = Bubble(
            id: UUID(),
            position: position,
            color: color,
            radius: radius,
            lifetime: max(0.8, lifetime),
            spawnTime: Date()
        )
        bubbles.append(bubble)
    }

    private func randomPosition(radius: CGFloat, existingBubbles: [Bubble], gameSize: CGSize) -> CGPoint {
        let margin: CGFloat = radius + 4
        let hudHeight: CGFloat = 100
        let minX = margin
        let maxX = gameSize.width - margin
        let minY = hudHeight + margin
        let maxY = gameSize.height - margin - 20

        guard maxX > minX, maxY > minY else {
            return CGPoint(x: gameSize.width / 2, y: gameSize.height / 2)
        }

        for _ in 0..<12 {
            let x = CGFloat.random(in: minX...maxX)
            let y = CGFloat.random(in: minY...maxY)
            let candidate = CGPoint(x: x, y: y)

            // Reject if too close to existing bubbles
            let tooClose = existingBubbles.contains { existing in
                let dx = existing.position.x - x
                let dy = existing.position.y - y
                let minDist = existing.radius + radius + 8
                return (dx * dx + dy * dy) < (minDist * minDist)
            }

            if !tooClose {
                return candidate
            }
        }

        // Fallback: just place it
        return CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }
}
