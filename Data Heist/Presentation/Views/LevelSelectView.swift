//
//  LevelSelectView.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import SwiftUI
import SwiftData

struct LevelSelectView: View {
    @Query private var stats: [PlayerStats]
    @Environment(\.dismiss) var dismiss
    
    // YENİ NAVİGASYON DURUMLARI
    @State private var selectedLevelToPlay: Int = 1
    @State private var navigateToGame: Bool = false
    
    private var unlockedLevel: Int { stats.first?.unlockedLevel ?? 1 }
    let columns = [GridItem(.adaptive(minimum: 70))]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            MatrixRainEffect()
            
            VStack(spacing: 30) {
                Text("ERİŞİM NOKTALARI")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(.green).glow()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(1...20, id: \.self) { level in
                            LevelButton(level: level,
                                        isLocked: level > unlockedLevel,
                                        isActive: false) {
                                // Butona basılınca seviyeyi kaydet ve oyuna geçişi tetikle
                                selectedLevelToPlay = level
                                navigateToGame = true
                            }
                        }
                    }
                    .padding()
                }
                
                Button("ANA MENÜ") { dismiss() }
                    .font(.system(size: 16, design: .monospaced)).foregroundColor(.gray)
            }
            .padding()
        }
        // BUG'I ÇÖZEN KISIM: fullScreenCover yerine temiz bir sayfa geçişi (navigationDestination) kullanıyoruz.
        .navigationDestination(isPresented: $navigateToGame) {
            GameView(startingLevel: selectedLevelToPlay)
                .navigationBarBackButtonHidden(true) // Oyun ekranında üstteki geri tuşunu gizler
        }
    }
}

// MARK: - ALT BİLEŞENLER
struct LevelButton: View {
    let level: Int
    let isLocked: Bool
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isLocked ? Color.gray : Color.green, lineWidth: 2)
                    .background(isLocked ? Color.gray.opacity(0.1) : (isActive ? Color.green : Color.green.opacity(0.1)))
                
                if isLocked {
                    Image(systemName: "lock.fill").foregroundColor(.gray)
                } else {
                    Text("\(level)").font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(isActive ? .black : .white)
                }
            }
            .frame(width: 70, height: 70)
        }.disabled(isLocked)
    }
}

extension Int: Identifiable { public var id: Int { self } }
