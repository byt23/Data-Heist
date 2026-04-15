//
//  GameViewModel.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class GameViewModel {
    var modelContext: ModelContext?
    
    var dataPoints: [DataPoint] = []
    var score: Int = 0
    var terminalMessage: String = "SİSTEM İZLENİYOR..."
    var timeLeft: Int = 15
    var isGameOver: Bool = false
    var isVictory: Bool = false
    var currentLevel: Int = 1
    
    var powerUpsRemaining: Int = 2
    var isTimeFrozen: Bool = false
    var combo: Int = 0
    var ipDetection: Double = 0.0
    var cyberCoinsEarned: Int = 0
    
    private var timer: Timer?
    private let engine = GameEngine()
    
    func startHackTrace(level: Int = 1, resetGame: Bool = true) {
        if resetGame {
            score = 0
            cyberCoinsEarned = 0
            powerUpsRemaining = 2
        }
        
        self.isVictory = false
        self.isGameOver = false
        self.currentLevel = level
        self.combo = 0
        self.ipDetection = 0.0
        self.isTimeFrozen = false
        
        let currentAnomalyCount = min(12, 2 + currentLevel)
        let calculatedTime = max(5, 15 - (currentLevel / 2))
        
        timeLeft = calculatedTime
        dataPoints = engine.generateDataSet(pointCount: 20, anomalyCount: currentAnomalyCount, level: currentLevel)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        guard !isTimeFrozen && !isGameOver && !isVictory else { return }
        
        ipDetection += (0.5 + (Double(currentLevel) * 0.2))
        if ipDetection >= 100.0 {
            triggerGameOver(reason: "SİBER POLİS TARAFINDAN TESPİT EDİLDİN!")
            return
        }
        
        if timeLeft > 0 {
            timeLeft -= 1
        } else {
            triggerGameOver(reason: "SÜRE BİTTİ: SİSTEM ÇÖKTÜ!")
        }
    }
    
    private func triggerGameOver(reason: String) {
        timer?.invalidate()
        isGameOver = true
        terminalMessage = reason
        HapticManager.shared.triggerNotification(type: .error)
    }
    
    func usePowerUp() {
        guard powerUpsRemaining > 0 && !isTimeFrozen && !isGameOver && !isVictory else { return }
        powerUpsRemaining -= 1
        isTimeFrozen = true
        terminalMessage = "JOKER AKTİF: ZAMAN 5 SN DONDURULDU!"
        HapticManager.shared.triggerImpact(style: .heavy)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self, !self.isGameOver, !self.isVictory else { return }
            self.isTimeFrozen = false
            self.terminalMessage = "UYARI: ZAMAN AKIŞI NORMALE DÖNDÜ!"
        }
    }
    
    func inspectNode(_ point: DataPoint) {
        guard !isGameOver && !isVictory else { return }
        
        if point.isAnomaly {
            combo += 1
            let basePoints = point.anomalyType == .drop ? 150 : 100
            let pointsEarned = basePoints * combo
            
            score += pointsEarned
            cyberCoinsEarned += (10 * combo)
            ipDetection = max(0, ipDetection - 5.0)
            
            terminalMessage = combo > 1 ? "KOMBO x\(combo)! (+\(pointsEarned))" : "TEHDİT ENGELLENDİ! (+\(pointsEarned))"
            HapticManager.shared.triggerNotification(type: .success)
            neutralizeThreat(at: point)
            checkLevelClear()
        } else {
            combo = 0
            score -= 50
            timeLeft -= 2
            ipDetection += 15.0
            terminalMessage = "HATA: KOMBO KIRILDI! IP İZLENİYOR!"
            HapticManager.shared.triggerNotification(type: .error)
            
            if ipDetection >= 100.0 {
                triggerGameOver(reason: "SİBER POLİS TARAFINDAN TESPİT EDİLDİN!")
            }
        }
    }
    
    private func neutralizeThreat(at point: DataPoint) {
        if let index = dataPoints.firstIndex(where: { $0.id == point.id }) {
            let safePoint = DataPoint(timestamp: point.timestamp, value: Double.random(in: 10...40), anomalyType: .none)
            dataPoints[index] = safePoint
        }
    }
    
    private func checkLevelClear() {
        let remainingAnomalies = dataPoints.filter { $0.isAnomaly }.count
        if remainingAnomalies == 0 {
            timer?.invalidate()
            isVictory = true
            terminalMessage = "ERİŞİM BAŞARILI. SİSTEM VERİLERİ SIZDIRILDI."
            HapticManager.shared.triggerNotification(type: .success)
            saveProgress()
        }
    }
    
    private func saveProgress() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<PlayerStats>()
        do {
            let statsList = try context.fetch(descriptor)
            let stats: PlayerStats
            
            if let existingStats = statsList.first {
                stats = existingStats
            } else {
                stats = PlayerStats()
                context.insert(stats)
            }
            
            if currentLevel == stats.unlockedLevel && stats.unlockedLevel < 20 {
                stats.unlockedLevel += 1
            }
            
            stats.cyberCoins += cyberCoinsEarned
            stats.totalHacksPrevented += 1
            if score > stats.highScore {
                stats.highScore = score
            }
            
            try context.save()
        } catch {
            print("Veritabanı kayıt hatası: \(error)")
        }
    }
}
