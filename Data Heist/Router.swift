//
//  Router.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import SwiftUI

@Observable
class Router {
    // ÇÖZÜM: Equatable eklendi, artık animasyonlar sayfaları kıyaslayabilecek.
    enum Screen: Equatable {
        case menu
        case map
        case game(level: Int)
    }
    
    // Uygulama her zaman menüden başlar
    var currentScreen: Screen = .menu
}
