//
//  HelpView.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//

import SwiftUI

struct HelpView: View {
    // Modal'ı kapatmak için ortam değişkeni
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // BAŞLIK VE KAPATMA TUŞU
                HStack {
                    Text("BRİFİNG: SİSTEM PROTOKOLÜ")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 20)
                
                // HİKAYELEŞTİRİLMİŞ OYUN MANTIĞI
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        HelpSection(title: "HİKAYE:", content: "Cybernetics Corp. sunucularına küresel bir siber saldırı düzenleniyor. Sen, sistemin son savunma hattısın.")
                        
                        HelpSection(title: "GÖREVİN:", content: "Sana verilen zaman zarfında ağ trafiğindeki 'Anomalileri' (Hacker Saldırılarını) tespit et ve etkisiz hale getir.")
                        
                        HelpSection(title: "NASIL OYNANIR?", content: "Sunucu yük grafiğindeki normal veri akışı sakindir. Ancak bir hacker sızmaya çalıştığında grafikte 'YÜKSEK KIRMIZI TEPE NOKTALARI' (Spikes) oluşur. Bu kırmızı noktalara dokunarak saldırıyı engellemelisin.")
                        
                        // İPUCU
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DİKKAT!")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                            Text("- Her doğru dokunuş: **+100 Puan** kazandırır.")
                                .foregroundColor(.white)
                            Text("- Her yanlış dokunuş: **-50 Puan** ve **-2 Saniye** ceza verir.")
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 14, design: .monospaced))
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("PROTOKOLÜ ANLADIM")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green, lineWidth: 1))
                }
                .padding(.top, 20)
            }
            .padding(30)
            .background(Color.green.opacity(0.05))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.3), lineWidth: 2))
            .padding()
        }
    }
}

// Yardım ekranı için özel bölüm görünümü
struct HelpSection: View {
    let title: String
    let content: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
            Text(content)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white)
                .lineSpacing(4)
        }
    }
}
