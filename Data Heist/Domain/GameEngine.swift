//
//  GameEngine.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import Foundation

class GameEngine {
    
    // YENİ: Seviye bilgisini de alıyoruz
    func generateDataSet(pointCount: Int, anomalyCount: Int, level: Int) -> [DataPoint] {
        var data: [DataPoint] = []
        let baseDate = Date()
        
        for i in 0..<pointCount {
            let normalValue = Double.random(in: 10...40)
            data.append(DataPoint(timestamp: baseDate.addingTimeInterval(TimeInterval(i * 5)), value: normalValue, anomalyType: .none))
        }
        
        for _ in 0..<anomalyCount {
            let randomIndex = Int.random(in: 0..<pointCount)
            
            // YENİ: Seviye 2 ve üzerindeyken %50 ihtimalle "Drop (Mavi Çukur)" anomalisi üret
            let type: AnomalyType = (level >= 2 && Bool.random()) ? .drop : .spike
            
            // Spike ise 85-120 arası, Drop ise 0-5 arası değer alır
            let anomalyValue = type == .spike ? Double.random(in: 85...120) : Double.random(in: 0...5)
            
            data[randomIndex] = DataPoint(timestamp: data[randomIndex].timestamp, value: anomalyValue, anomalyType: type)
        }
        
        return data.sorted { $0.timestamp < $1.timestamp }
    }
}
