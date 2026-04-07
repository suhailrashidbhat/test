import SwiftUI

@main
struct BubblePopApp: App {
    @StateObject private var gameState = GameState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                if gameState.phase == .playing {
                    gameState.pauseGame()
                }
            }
        }
    }
}
