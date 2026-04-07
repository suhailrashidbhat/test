import SwiftUI

struct HUDView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Score
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(gameState.score)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.25), value: gameState.score)
                }

                Spacer()

                // Lives
                HStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < gameState.lives ? "heart.fill" : "heart")
                            .font(.system(size: 22))
                            .foregroundColor(i < gameState.lives ? Color(red: 1, green: 0.27, blue: 0.27) : .white.opacity(0.25))
                            .scaleEffect(i < gameState.lives ? 1.0 : 0.85)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: gameState.lives)
                    }
                }

                Spacer()

                // Level
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LEVEL")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(gameState.level)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.10, green: 0.75, blue: 1.00))
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.25), value: gameState.level)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.85), Color.black.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
}
