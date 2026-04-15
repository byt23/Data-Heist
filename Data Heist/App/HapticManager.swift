//
//  HapticManager.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import Foundation
import SwiftUI

// Cihazın titreşim motorunu yönetecek sınıf
class HapticManager {
    // Singleton mimarisi ile uygulamanın her yerinden kolayca ulaşılabilir yaptık
    static let shared = HapticManager()
    
    private init() {}
    
    // Doğru veya yanlış hamlelerde kullanılacak bildirim titreşimleri
    func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    // Ekrana dokunma hissiyatı veren hafif titreşimler
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
