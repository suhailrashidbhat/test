import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState

    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
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

                // Bubbles
                ForEach(gameState.bubbles) { bubble in
                    BubbleView(bubble: bubble)
                }

                // Miss flash overlay
                if gameState.showMissFlash {
                    Color.red.opacity(0.22)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }

                // Score popups
                ForEach(gameState.scorePopups) { popup in
                    ScorePopupView(popup: popup)
                }

                // Combo flash
                if gameState.showComboFlash {
                    ComboFlashView(multiplier: gameState.comboMultiplier)
                        .transition(.scale(scale: 2.0).combined(with: .opacity))
                }

                // Pause button
                VStack {
                    Spacer()
                    Button {
                        gameState.pauseGame()
                    } label: {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.bottom, 30)
                }

                // HUD (on top)
                VStack {
                    HUDView()
                    Spacer()
                }

                // Pause overlay
                if gameState.phase == .paused {
                    PauseOverlayView()
                }
            }
            .offset(x: shakeOffset)
            .onAppear {
                gameState.setGameSize(geo.size)
            }
            .onChange(of: geo.size) { newSize in
                gameState.setGameSize(newSize)
            }
            .onChange(of: gameState.shakeScreen) { shaking in
                if shaking {
                    withAnimation(.easeInOut(duration: 0.07).repeatCount(4, autoreverses: true)) {
                        shakeOffset = 7
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        shakeOffset = 0
                    }
                }
            }
        }
        .animation(.easeOut(duration: 0.25), value: gameState.showMissFlash)
        .animation(.spring(response: 0.25), value: gameState.showComboFlash)
    }
}

// MARK: - Score Popup

struct ScorePopupView: View {
    let popup: ScorePopup
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Text("+\(popup.value)")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.5), radius: 2)
            .offset(y: offset)
            .opacity(opacity)
            .position(popup.position)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) {
                    offset = -55
                    opacity = 0
                }
            }
        .allowsHitTesting(false)
    }
}

// MARK: - Combo Flash

struct ComboFlashView: View {
    let multiplier: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("COMBO!")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Text("x\(multiplier)")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 1.0, green: 0.88, blue: 0.10))
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 1.0, green: 0.88, blue: 0.10).opacity(0.6), lineWidth: 2)
                )
        )
        .allowsHitTesting(false)
    }
}

// MARK: - Pause Overlay

struct PauseOverlayView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("PAUSED")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Button {
                    gameState.resumeGame()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(Capsule())
                }

                Button {
                    gameState.phase = .menu
                } label: {
                    Text("Main Menu")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}
