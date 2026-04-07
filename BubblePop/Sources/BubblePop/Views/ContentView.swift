import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            switch gameState.phase {
            case .menu:
                MenuView()
                    .transition(.opacity)
            case .playing, .paused:
                GameView()
                    .transition(.opacity)
            case .gameOver:
                GameOverView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameState.phase)
        .preferredColorScheme(.dark)
    }
}
