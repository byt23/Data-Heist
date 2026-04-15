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
    
    // YENİ: Joker (Power-Up) Değişkenleri
    var powerUpsRemaining: Int = 2 // Her oyunda 2 kullanım hakkı
    var isTimeFrozen: Bool = false // Zamanın donup donmadığını takip eder
    
    private var timer: Timer?
    private let engine = GameEngine()
    
    func startHackTrace(resetGame: Bool = true) {
        if resetGame {
            score = 0
            currentLevel = 1
            isGameOver = false
            isVictory = false
            powerUpsRemaining = 2 // Yeni oyunda jokerleri sıfırla
        }
        
        // ZORLUK HESAPLAMASI
        let currentAnomalyCount = 2 + currentLevel
        let calculatedTime = max(7, 15 - (currentLevel * 2) + 2)
        
        timeLeft = calculatedTime
        isTimeFrozen = false // Yeni tura başlarken zaman donuk olmasın
        
        dataPoints = engine.generateDataSet(pointCount: 20, anomalyCount: currentAnomalyCount, level: currentLevel)
        terminalMessage = "SEVİYE \(currentLevel): AĞDA \(currentAnomalyCount) TEHDİT VAR!"
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        // YENİ: Zaman donmuşsa süreyi azaltma, doğrudan fonksiyondan çık!
        if isTimeFrozen { return }
        
        if timeLeft > 0 {
            timeLeft -= 1
        } else {
            timer?.invalidate()
            isGameOver = true
            terminalMessage = "SİSTEM ÇÖKTÜ: BAĞLANTI KOPARILDI!"
        }
    }
    
    // YENİ: Joker Kullanım Fonksiyonu
    func usePowerUp() {
        guard powerUpsRemaining > 0 && !isTimeFrozen && !isGameOver && !isVictory else { return }
        
        powerUpsRemaining -= 1
        isTimeFrozen = true
        terminalMessage = "JOKER AKTİF: ZAMAN 5 SN DONDURULDU!"
        HapticManager.shared.triggerImpact(style: .heavy)
        
        // 5 Saniye sonra zamanı tekrar normale döndür
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self, !self.isGameOver, !self.isVictory else { return }
            self.isTimeFrozen = false
            self.terminalMessage = "UYARI: ZAMAN AKIŞI NORMALE DÖNDÜ!"
        }
    }
    
    func inspectNode(_ point: DataPoint) {
        guard !isGameOver && !isVictory else { return }
        
        if point.isAnomaly {
            let pointsEarned = point.anomalyType == .drop ? 150 : 100
            score += pointsEarned
            terminalMessage = "BAŞARILI: TEHDİT ENGELLENDİ! (+\(pointsEarned))"
            
            HapticManager.shared.triggerNotification(type: .success)
            neutralizeThreat(at: point)
            checkLevelClear()
        } else {
            score -= 50
            // Zaman donmuş olsa bile yanlış tıklama anında cezalandırır!
            timeLeft -= 2
            terminalMessage = "HATA: YANLIŞ ALARM! (-50 Puan, -2 Sn)"
            HapticManager.shared.triggerNotification(type: .error)
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
            if currentLevel >= 5 {
                isVictory = true
                terminalMessage = "TÜM AĞ KURTARILDI. GÖREV TAMAM!"
            } else {
                currentLevel += 1
                startHackTrace(resetGame: false)
            }
        }
    }
}
