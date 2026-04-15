//
//  DataPoint.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import Foundation

// YENİ: Anomali Tipleri
enum AnomalyType {
    case none    // Temiz Veri (Yeşil)
    case spike   // Kırmızı Yüksek Tepe (Klasik Virüs)
    case drop    // Mavi Derin Çukur (DDoS Saldırısı)
}

struct DataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double
    let anomalyType: AnomalyType
    
    // Anomali olup olmadığını pratikçe kontrol etmek için
    var isAnomaly: Bool {
        return anomalyType != .none
    }
}
