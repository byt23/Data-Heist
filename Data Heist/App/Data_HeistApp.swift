//
//  Data_HeistApp.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import SwiftUI
import SwiftData

@main
struct DataHeistApp: App {
    @State private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch router.currentScreen {
                case .menu:
                    MainMenuView()
                case .map:
                    LevelSelectView()
                case .game(let level):
                    GameView(startingLevel: level)
                }
            }
            .environment(router) // Router'ı tüm sayfalara dağıt
            .animation(.easeInOut(duration: 0.2), value: router.currentScreen) // Yumuşak geçiş
        }
        .modelContainer(for: PlayerStats.self)
    }
}
