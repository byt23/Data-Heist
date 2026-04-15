//
//  PlayerStats.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import Foundation
import SwiftData

@Model
final class PlayerStats {
    var highScore: Int
    var totalHacksPrevented: Int
    var unlockedLevel: Int
    var cyberCoins: Int
    var lastLogin: Date
    
    init(
        highScore: Int = 0,
        totalHacksPrevented: Int = 0,
        unlockedLevel: Int = 1,
        cyberCoins: Int = 0
    ) {
        self.highScore = highScore
        self.totalHacksPrevented = totalHacksPrevented
        self.unlockedLevel = unlockedLevel
        self.cyberCoins = cyberCoins
        self.lastLogin = Date()
    }
}
