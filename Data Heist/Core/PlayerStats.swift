//
//  PlayerStats.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import Foundation
import SwiftData

@Model
class PlayerStats {
    var highScore: Int = 0
    var totalHacksPrevented: Int = 0
    var unlockedLevel: Int = 1 // BURASI EKSİK OLDUĞU İÇİN HATA ALIYORSUN
    var cyberCoins: Int = 0
    var lastLogin: Date = Date()
    
    init(highScore: Int = 0, totalHacksPrevented: Int = 0, unlockedLevel: Int = 1, cyberCoins: Int = 0) {
        self.highScore = highScore
        self.totalHacksPrevented = totalHacksPrevented
        self.unlockedLevel = unlockedLevel
        self.cyberCoins = cyberCoins
        self.lastLogin = Date()
    }
}
