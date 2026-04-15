//
//  MainMenuView.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import SwiftUI
import SwiftData

struct MainMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stats: [PlayerStats]
    
    @State private var navigateToGame = false
    @State private var navigateToMap = false // YENİ: Harita için güvenli yönlendirme durumu
    @State private var showingHelp = false
    @State private var navigationId = UUID()
    
    private var playerStats: PlayerStats {
        if let existing = stats.first { return existing }
        else { return PlayerStats() }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                MatrixRainEffect()
                
                VStack(spacing: 25) {
                    // ÜST ARAÇ ÇUBUĞU
                    HStack {
                        Spacer()
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
                    
                    // BAŞLIK
                    VStack(spacing: 8) {
                        Text("DATA-HEIST")
                            .font(.system(size: 48, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
                            .glow()
                        
                        Text("TERMINAL HACKER")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(4)
                    }
                    
                    Spacer()
                    
                    // SİSTEM GÜNLÜĞÜ (İSTATİSTİKLER)
                    VStack(alignment: .leading, spacing: 15) {
                        Label("SİSTEM GÜNLÜĞÜ", systemImage: "terminal.fill")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .padding(.bottom, 5)
                        
                        Divider().background(Color.green.opacity(0.3))
                        
                        StatRow(title: "YÜKSEK SKOR", value: "\(playerStats.highScore)")
                        StatRow(title: "AÇIK SEVİYE", value: "\(playerStats.unlockedLevel)")
                        StatRow(title: "SİBER COIN", value: "₿\(playerStats.cyberCoins)")
                    }
                    .padding(25)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.green.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // BUTONLAR
                    VStack(spacing: 15) {
                        // 1. SİSTEMİ BAŞLAT
                        Button(action: {
                            HapticManager.shared.triggerImpact(style: .heavy)
                            navigateToGame = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
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
                        
                        // 2. SEVİYE SEÇİMİ (BURASI DEĞİŞTİ - Bug'ı çözecek kısım)
                        Button(action: {
                            HapticManager.shared.triggerImpact(style: .medium)
                            navigateToMap = true
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("SEVİYE SEÇİMİ")
                            }
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Text("© 2026 CYBERNETICS CORP.")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.bottom, 10)
                }
            }
            // --- GÜVENLİ YÖNLENDİRMELER (Eski NavigationLink sorununu çözer) ---
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(startingLevel: playerStats.unlockedLevel)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToMap) {
                LevelSelectView()
                    .navigationBarBackButtonHidden(true)
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
        }
        .id(navigationId)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GoToRoot"))) { _ in
            navigationId = UUID()
        }
        .onAppear {
            if stats.isEmpty {
                let initialStats = PlayerStats()
                modelContext.insert(initialStats)
                try? modelContext.save()
            }
        }
    }
}

// MARK: - TAM EKRAN MATRIX RAIN BİLEŞENİ
struct MatrixRainEffect: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let columns = Int(size.width / 18)
            
            HStack(spacing: 2) {
                ForEach(0..<columns, id: \.self) { _ in
                    MatrixRainColumn(screenHeight: size.height)
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct MatrixRainColumn: View {
    let screenHeight: CGFloat
    @State private var startAnimation = false
    
    private let duration = Double.random(in: 4...10)
    private let delay = Double.random(in: 0...5)
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<45, id: \.self) { _ in
                Text(String(Int.random(in: 0...1)))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                    .opacity(0.15)
                    .padding(.bottom, 2)
            }
        }
        .mask(
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: [.clear, .black, .clear]), startPoint: .top, endPoint: .bottom))
                .frame(height: 600)
                .offset(y: startAnimation ? screenHeight + 600 : -600)
        )
        .onAppear {
            withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false).delay(delay)) {
                startAnimation = true
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title).font(.system(size: 14, design: .monospaced)).foregroundColor(.gray)
            Spacer()
            Text(value).font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(.white)
        }
    }
}

extension View {
    func glow(color: Color = .green, radius: CGFloat = 8) -> some View {
        self.shadow(color: color, radius: radius).shadow(color: color, radius: radius / 2)
    }
}
