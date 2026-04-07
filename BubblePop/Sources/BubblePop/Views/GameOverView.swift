import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var gameState: GameState

    @State private var displayedScore: Int = 0
    @State private var showContent: Bool = false
    @State private var showHighScore: Bool = false
    @State private var confettiOpacity: Double = 0

    private let isNewHighScore: Bool

    init() {
        // Capture at init time — before we start counting up
        isNewHighScore = false  // will be set via onAppear logic
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.12),
                    Color(red: 0.07, green: 0.03, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Confetti dots for new high score
            if gameState.score >= gameState.highScore && gameState.score > 0 {
                ConfettiView()
                    .opacity(confettiOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                Spacer()

                Text("GAME OVER")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)

                // Score count-up
                Text("\(displayedScore)")
                    .font(.system(size: 90, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.10, green: 0.75, blue: 1.00),
                                Color(red: 0.75, green: 0.35, blue: 1.00)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText())
                    .padding(.top, 8)
                    .opacity(showContent ? 1 : 0)

                Text("points")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .opacity(showContent ? 1 : 0)

                // New high score badge
                if gameState.score >= gameState.highScore && gameState.score > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.88, blue: 0.10))
                        Text("NEW HIGH SCORE!")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.88, blue: 0.10))
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.88, blue: 0.10))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 1.0, green: 0.88, blue: 0.10).opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 1.0, green: 0.88, blue: 0.10).opacity(0.5), lineWidth: 1.5)
                            )
                    )
                    .padding(.top, 16)
                    .scaleEffect(showHighScore ? 1.0 : 0.4)
                    .opacity(showHighScore ? 1 : 0)
                } else {
                    // Show personal best
                    VStack(spacing: 4) {
                        Text("BEST")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                        Text("\(gameState.highScore)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    .opacity(showContent ? 1 : 0)
                }

                Spacer()

                // Buttons
                VStack(spacing: 16) {
                    Button {
                        gameState.startGame()
                    } label: {
                        Text("PLAY AGAIN")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .frame(width: 220, height: 58)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.10, green: 0.75, blue: 1.00),
                                        Color(red: 0.75, green: 0.35, blue: 1.00)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color(red: 0.10, green: 0.75, blue: 1.00).opacity(0.4), radius: 14)
                    }

                    Button {
                        withAnimation {
                            gameState.phase = .menu
                        }
                    } label: {
                        Text("Main Menu")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .opacity(showContent ? 1 : 0)

                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }

            // Count-up animation
            let targetScore = gameState.score
            let duration: Double = 1.0
            let steps = min(targetScore, 60)
            if steps > 0 {
                let interval = duration / Double(steps)
                var current = 0
                Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                    current += max(1, targetScore / steps)
                    if current >= targetScore {
                        displayedScore = targetScore
                        timer.invalidate()
                    } else {
                        displayedScore = current
                    }
                }
            } else {
                displayedScore = 0
            }

            // New high score badge
            if gameState.score >= gameState.highScore && gameState.score > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                        showHighScore = true
                    }
                    withAnimation(.easeIn(duration: 0.3)) {
                        confettiOpacity = 1
                    }
                }
            }
        }
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    private struct Dot: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let color: Color
        let size: CGFloat
        let delay: Double
    }

    private let dots: [Dot] = (0..<40).map { _ in
        Dot(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            color: Bubble.palette.randomElement()!,
            size: CGFloat.random(in: 5...12),
            delay: Double.random(in: 0...0.8)
        )
    }

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ForEach(dots) { dot in
                Circle()
                    .fill(dot.color)
                    .frame(width: dot.size, height: dot.size)
                    .position(
                        x: geo.size.width * dot.x,
                        y: animate
                            ? geo.size.height * dot.y
                            : -20
                    )
                    .opacity(animate ? 0.8 : 0)
                    .animation(
                        .easeOut(duration: 1.5).delay(dot.delay),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
