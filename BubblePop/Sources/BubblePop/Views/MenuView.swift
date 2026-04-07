import SwiftUI

struct MenuView: View {
    @EnvironmentObject var gameState: GameState

    @State private var bubble1Scale: CGFloat = 1.0
    @State private var bubble2Scale: CGFloat = 0.9
    @State private var bubble3Scale: CGFloat = 1.1
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var playPulse: CGFloat = 1.0

    private let decorBubbles: [(color: Color, size: CGFloat, x: CGFloat, y: CGFloat)] = [
        (Color(red: 1.0, green: 0.27, blue: 0.27), 90, 0.15, 0.22),
        (Color(red: 0.10, green: 0.75, blue: 1.00), 65, 0.80, 0.30),
        (Color(red: 0.75, green: 0.35, blue: 1.00), 75, 0.50, 0.15),
        (Color(red: 0.20, green: 0.90, blue: 0.40), 50, 0.20, 0.60),
        (Color(red: 1.0, green: 0.60, blue: 0.10), 80, 0.82, 0.65),
        (Color(red: 1.0, green: 0.88, blue: 0.10), 55, 0.60, 0.80),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.04, blue: 0.12),
                        Color(red: 0.07, green: 0.03, blue: 0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Decorative background bubbles
                ForEach(0..<decorBubbles.count, id: \.self) { i in
                    let b = decorBubbles[i]
                    Circle()
                        .fill(b.color.opacity(0.15))
                        .frame(width: b.size, height: b.size)
                        .position(x: geo.size.width * b.x, y: geo.size.height * b.y)
                        .blur(radius: 6)
                }

                VStack(spacing: 0) {
                    Spacer()

                    // Animated title bubbles
                    HStack(spacing: -12) {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.27, blue: 0.27))
                            .frame(width: 36, height: 36)
                            .scaleEffect(bubble1Scale)
                        Circle()
                            .fill(Color(red: 0.10, green: 0.75, blue: 1.00))
                            .frame(width: 28, height: 28)
                            .scaleEffect(bubble2Scale)
                            .offset(y: -6)
                        Circle()
                            .fill(Color(red: 0.75, green: 0.35, blue: 1.00))
                            .frame(width: 32, height: 32)
                            .scaleEffect(bubble3Scale)
                    }
                    .padding(.bottom, 16)

                    // Title
                    Text("Bubble Pop")
                        .font(.system(size: 52, weight: .black, design: .rounded))
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
                        .shadow(color: Color(red: 0.10, green: 0.75, blue: 1.00).opacity(0.4), radius: 12)
                        .opacity(titleOpacity)

                    Text("Tap fast. Pop all.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 8)
                        .opacity(contentOpacity)

                    Spacer()

                    // High score
                    if gameState.highScore > 0 {
                        VStack(spacing: 4) {
                            Text("BEST")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.45))
                            Text("\(gameState.highScore)")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 36)
                        .opacity(contentOpacity)
                    }

                    // Play button
                    Button {
                        gameState.startGame()
                    } label: {
                        Text("PLAY")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .frame(width: 180, height: 60)
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
                            .shadow(color: Color(red: 0.10, green: 0.75, blue: 1.00).opacity(0.5), radius: 16)
                    }
                    .scaleEffect(playPulse)
                    .opacity(contentOpacity)

                    // How to play hint
                    Text("Tap bubbles before they vanish!")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .padding(.top, 16)
                        .opacity(contentOpacity)

                    Spacer()
                        .frame(height: 60)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    titleOpacity = 1
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                    contentOpacity = 1
                }
                // Bouncing bubbles
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    bubble1Scale = 1.18
                }
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.15)) {
                    bubble2Scale = 1.12
                }
                withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true).delay(0.3)) {
                    bubble3Scale = 0.88
                }
                // Play button pulse
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.5)) {
                    playPulse = 1.06
                }
            }
        }
    }
}
