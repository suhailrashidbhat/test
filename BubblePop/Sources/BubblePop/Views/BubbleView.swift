import SwiftUI

struct BubbleView: View {
    let bubble: Bubble
    @EnvironmentObject var gameState: GameState

    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1.0
    @State private var popScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Glow shadow
            Circle()
                .fill(bubble.color.opacity(0.3))
                .frame(width: bubble.radius * 2.6, height: bubble.radius * 2.6)
                .blur(radius: 10)

            // Bubble body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [bubble.color.opacity(0.9), bubble.color],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: bubble.radius * 1.8
                    )
                )
                .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                .overlay(
                    // Specular highlight
                    Ellipse()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: bubble.radius * 0.8, height: bubble.radius * 0.5)
                        .offset(x: -bubble.radius * 0.15, y: -bubble.radius * 0.25)
                )

            // Countdown ring
            Circle()
                .trim(from: 0, to: CGFloat(1.0 - progress))
                .stroke(bubble.ringColor, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .frame(width: bubble.radius * 2 + 8, height: bubble.radius * 2 + 8)
                .rotationEffect(.degrees(-90))
        }
        .scaleEffect(scale * popScale)
        .opacity(opacity)
        .position(bubble.position)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                scale = 1.0
            }
        }
        .onChange(of: bubble.isPopped) { popped in
            if popped {
                withAnimation(.easeOut(duration: 0.28)) {
                    popScale = 1.7
                    opacity = 0
                }
            }
        }
        .onTapGesture {
            guard !bubble.isPopped else { return }
            gameState.tapBubble(id: bubble.id)
        }
        // Force re-render each tick so progress ring updates
        .onChange(of: gameState.tick) { _ in }
    }

    // Use current time so the ring animates smoothly between ticks
    private var progress: Double {
        bubble.progress
    }
}
