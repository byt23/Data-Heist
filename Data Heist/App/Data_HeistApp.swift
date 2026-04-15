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
    // SwiftData için model konteynerini oluştur
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: PlayerStats.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            // Uygulama artık Ana Menü'den başlar
            MainMenuView()
                // SwiftData konteynerini tüm görünümlere sun
                .modelContainer(container)
        }
    }
}
