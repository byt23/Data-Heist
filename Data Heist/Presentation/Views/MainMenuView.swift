//
//  MainMenuView.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import SwiftUI
import SwiftData

struct MainMenuView: View {
    @Query private var stats: [PlayerStats]
    @State private var navigateToGame = false
    @State private var showingHelp = false
    
    private var playerStats: PlayerStats {
        if let existing = stats.first { return existing }
        else { return PlayerStats() }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                MatrixEffect()
                
                // ANA AKIŞ
                VStack(spacing: 20) {
                    
                    // YENİ: Soru İşareti tuşunu ana akışın en üstüne taşıdık.
                    // Böylece başlıkla üst üste binmesi imkansız hale geldi.
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.shared.triggerImpact(style: .medium)
                            showingHelp = true
                        }) {
                            Image(systemName: "questionmark")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .frame(width: 35, height: 35)
                                .foregroundColor(.black)
                                .background(Color.green)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(color: .green.opacity(0.5), radius: 5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // OYUN BAŞLIĞI
                    VStack(spacing: 10) {
                        Text("DATA-HEIST")
                            .font(.system(size: 48, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
                            .glow()
                        
                        Text("TERMINAL HACKER")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // İSTATİSTİKLER PANELİ
                    VStack(alignment: .leading, spacing: 15) {
                        Text("SİSTEM GÜNLÜĞÜ:")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        StatRow(title: "YÜKSEK SKOR", value: "\(playerStats.highScore)")
                        StatRow(title: "ÖNLENEN SIZMA", value: "\(playerStats.totalHacksPrevented)")
                        StatRow(title: "SON GİRİŞ", value: playerStats.lastLogin.formatted(.relative(presentation: .named)))
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 30) // Kenar boşluklarını biraz artırdık
                    
                    Spacer()
                    
                    // BAŞLATMA TUŞU
                    Button(action: {
                        HapticManager.shared.triggerImpact(style: .heavy)
                        navigateToGame = true
                    }) {
                        Text("SİSTEMİ BAŞLAT")
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2))
                    }
                    .padding(.horizontal, 30)
                    
                    Text("© 2026 CYBERNETICS CORP.")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $navigateToGame) {
                GameView()
                    .navigationBarBackButtonHidden(true)
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
        }
    }
}

// Yardımcı İstatistik Satırı
struct StatRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title).font(.system(size: 16, design: .monospaced)).foregroundColor(.green.opacity(0.8))
            Spacer()
            Text(value).font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(.white)
        }
    }
}

// Parlama Efekti
extension View {
    func glow(color: Color = .green, radius: CGFloat = 10) -> some View {
        self.shadow(color: color, radius: radius).shadow(color: color, radius: radius)
    }
}

// Matrix Efekti
struct MatrixEffect: View {
    var body: some View {
        GeometryReader { _ in
            ForEach(0..<20) { _ in
                Text("101001100101")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.green.opacity(0.1))
                    .rotationEffect(.degrees(90))
                    .offset(x: CGFloat.random(in: 0...400), y: CGFloat.random(in: 0...800))
                    .animation(Animation.easeInOut(duration: 5).repeatForever().delay(Double.random(in: 0...5)), value: UUID())
            }
        }
    }
}
