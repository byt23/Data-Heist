//
//  GameViewModel.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import Foundation
import SwiftUI

@Observable
class GameViewModel {
    var dataPoints: [DataPoint] = []
    var score: Int = 0
    var terminalMessage: String = "SİSTEM İZLENİYOR..."
    
    var timeLeft: Int = 15
    var isGameOver: Bool = false
    var isVictory: Bool = false
    var currentLevel: Int = 1
    
    // YENİ OYUN MEKANİKLERİ
    var powerUpsRemaining: Int = 2
    var isTimeFrozen: Bool = false
    
    var combo: Int = 0 // Kombo sayacı
    var ipDetection: Double = 0.0 // IP Tespit Barı (0.0 - 100.0 arası)
    var cyberCoinsEarned: Int = 0 // Dükkanda harcamak için kazanılan para
    
    private var timer: Timer?
    private let engine = GameEngine()
    
    func startHackTrace(level: Int = 1, resetGame: Bool = true) {
        if resetGame {
            score = 0
            cyberCoinsEarned = 0
            isGameOver = false
            isVictory = false // Başlangıçta zafer ekranını kapat
            powerUpsRemaining = 2
        }
        
        // KRİTİK EKLEME: Her yeni seviye başladığında zafer ve oyun bitti durumlarını sıfırla
        self.isVictory = false
        self.isGameOver = false
        
        currentLevel = level
        combo = 0
        ipDetection = 0.0
        isTimeFrozen = false
        
        // ... (Kodun geri kalanı aynı kalıyor)
        let currentAnomalyCount = min(12, 2 + currentLevel)
        let calculatedTime = max(5, 15 - (currentLevel / 2))
        
        timeLeft = calculatedTime
        dataPoints = engine.generateDataSet(pointCount: 20, anomalyCount: currentAnomalyCount, level: currentLevel)
        
        // Seviye mesajları vb...
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        if isTimeFrozen { return }
        
        // IP BARI HER SANİYE DOLAR (Seviye arttıkça daha hızlı dolar)
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
            // YENİ: KOMBO SİSTEMİ
            combo += 1
            let basePoints = point.anomalyType == .drop ? 150 : 100
            let pointsEarned = basePoints * combo // Kombo ile puan katlanır!
            
            score += pointsEarned
            cyberCoinsEarned += (10 * combo) // Dükkan parası da katlanır
            
            // IP Barını biraz düşür (Sistemi rahatlat)
            ipDetection = max(0, ipDetection - 5.0)
            
            terminalMessage = combo > 1 ? "KOMBO x\(combo)! (+\(pointsEarned))" : "TEHDİT ENGELLENDİ! (+\(pointsEarned))"
            HapticManager.shared.triggerNotification(type: .success)
            neutralizeThreat(at: point)
            checkLevelClear()
        } else {
            // YENİ: HATA CEZALARI EKLENDİ
            combo = 0 // Kombo sıfırlanır
            score -= 50
            timeLeft -= 2
            ipDetection += 15.0 // Yanlış alarm FBI'ın dikkatini çeker!
            
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
            terminalMessage = "SEVİYE \(currentLevel) TAMAMLANDI!"
            
            // ÖNEMLİ: SwiftData üzerinden unlockedLevel'ı güncelleme tetikleyicisi buraya gelecek
        }
    }
}
