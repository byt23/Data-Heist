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
                // Arka Plan
                Color.black.ignoresSafeArea()
                
                // MEŞHUR MATRIX EFEKTİ (Silinmedi, burada akmaya devam ediyor)
                MatrixEffect()
                
                VStack(spacing: 25) {
                    
                    // ÜST ARAÇ ÇUBUĞU
                    HStack {
                        Spacer()
                        // Soru işareti butonu - Sağ üstte daha profesyonel duruyor
                        Button(action: {
                            HapticManager.shared.triggerImpact(style: .medium)
                            showingHelp = true
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                                .shadow(color: .green.opacity(0.6), radius: 5)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    
                    // BAŞLIK ALANI
                    VStack(spacing: 8) {
                        Text("DATA-HEIST")
                            .font(.system(size: 48, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
                            .glow() // Parlama efekti
                        
                        Text("TERMINAL HACKER")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(4) // Harf arası boşluk
                    }
                    
                    Spacer()
                    
                    // İSTATİSTİKLER PANELİ (Sistem Günlüğü)
                    VStack(alignment: .leading, spacing: 15) {
                        Label("SİSTEM GÜNLÜĞÜ", systemImage: "terminal.fill")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .padding(.bottom, 5)
                        
                        Divider().background(Color.green.opacity(0.3))
                        
                        StatRow(title: "YÜKSEK SKOR", value: "\(playerStats.highScore)")
                        StatRow(title: "ÖNLENEN SIZMA", value: "\(playerStats.totalHacksPrevented)")
                        StatRow(title: "SON GİRİŞ", value: playerStats.lastLogin.formatted(.relative(presentation: .named)))
                    }
                    .padding(25)
                    .background(Color.green.opacity(0.05))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // AKSİYON BUTONU
                    Button(action: {
                        HapticManager.shared.triggerImpact(style: .heavy)
                        navigateToGame = true
                    }) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("SİSTEMİ BAŞLAT")
                        }
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.4), radius: 10)
                    }
                    .padding(.horizontal, 30)
                    
                    Text("© 2026 CYBERNETICS CORP.")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.bottom, 10)
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

// MARK: - YARDIMCI GÖRÜNÜMLER

struct StatRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

struct MatrixEffect: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
            ForEach(0..<25) { _ in
                MatrixColumn(height: height)
                    .offset(x: CGFloat.random(in: 0...width))
            }
        }
        .ignoresSafeArea()
    }
}

struct MatrixColumn: View {
    let height: CGFloat
    @State private var offset: CGFloat = -500
    
    var body: some View {
        Text(generateRandomBinary())
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.green.opacity(0.15))
            .fixedSize()
            .rotationEffect(.degrees(0))
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: Double.random(in: 10...20))
                        .repeatForever(autoreverses: false)
                        .delay(Double.random(in: 0...10))
                ) {
                    offset = height + 500
                }
            }
    }
    
    func generateRandomBinary() -> String {
        var str = ""
        for _ in 0..<30 {
            str += "\(Int.random(in: 0...1))\n"
        }
        return str
    }
}

extension View {
    func glow(color: Color = .green, radius: CGFloat = 8) -> some View {
        self.shadow(color: color, radius: radius)
            .shadow(color: color, radius: radius / 2)
    }
}
