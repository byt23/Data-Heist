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
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        // KRİTİK: Tüm uygulamanın PlayerStats veritabanına erişmesini sağlar
        .modelContainer(for: PlayerStats.self)
    }
}
