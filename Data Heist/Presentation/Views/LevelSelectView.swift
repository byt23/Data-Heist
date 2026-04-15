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
    @State private var selectedLevel: Int? = nil
    
    // Oyuncunun ulaştığı seviyeyi al (Varsayılan 1)
    private var unlockedLevel: Int {
        stats.first?.unlockedLevel ?? 1
    }
    
    // Grid düzeni (Satırda 4 buton)
    let columns = [GridItem(.adaptive(minimum: 70))]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                MatrixEffect()
                
                VStack(spacing: 30) {
                    Text("ERİŞİM NOKTALARI")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.green)
                        .glow()
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(1...20, id: \.self) { level in
                                LevelButton(level: level,
                                            isLocked: level > unlockedLevel,
                                            isActive: level == selectedLevel) {
                                    selectedLevel = level
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Button("GERİ DÖN") {
                        dismiss()
                    }
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(.gray)
                }
                .padding()
            }
            .navigationDestination(item: $selectedLevel) { level in
                GameView(startingLevel: level)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

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
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                } else {
                    Text("\(level)")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(isActive ? .black : .white)
                }
            }
            .frame(width: 70, height: 70)
        }
        .disabled(isLocked)
    }
}
