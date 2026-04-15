//
//  PlayerStats.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import Foundation
import SwiftData

// SwiftData modelimiz: Cihazda saklanacak veriler
@Model
class PlayerStats {
    var totalHacksPrevented: Int = 0
    var highScore: Int = 0
    var lastLogin: Date = Date()
    
    init(totalHacksPrevented: Int = 0, highScore: Int = 0, lastLogin: Date = Date()) {
        self.totalHacksPrevented = totalHacksPrevented
        self.highScore = highScore
        self.lastLogin = lastLogin
    }
}
