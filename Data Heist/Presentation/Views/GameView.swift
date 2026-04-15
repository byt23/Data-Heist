//
//  GameView.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//


import SwiftUI
import Charts

struct GameView: View {
    @State private var viewModel = GameViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // ÜST BİLGİ PANELİ
                HStack {
                    if viewModel.isGameOver || viewModel.isVictory {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("SEVİYE: \(viewModel.currentLevel)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            
                        Text("SKOR: \(viewModel.score)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("SÜRE: \(viewModel.timeLeft) SN")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(viewModel.isTimeFrozen ? .cyan : (viewModel.timeLeft <= 5 ? .red : .green))
                            .blinkEffect(isActive: viewModel.timeLeft <= 5 && !viewModel.isGameOver && !viewModel.isVictory && !viewModel.isTimeFrozen)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // TERMİNAL MESAJ EKRANI
                Text(viewModel.terminalMessage)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(viewModel.isTimeFrozen ? .cyan : (viewModel.terminalMessage.contains("HATA") || viewModel.isGameOver ? .red : .green))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // GRAFİK EKRANI
                if !viewModel.dataPoints.isEmpty {
                    Chart(viewModel.dataPoints) { point in
                        LineMark(
                            x: .value("Zaman", point.timestamp),
                            y: .value("Veri Yükü", point.value)
                        )
                        .foregroundStyle(Color.green.opacity(0.8))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        PointMark(
                            x: .value("Zaman", point.timestamp),
                            y: .value("Veri Yükü", point.value)
                        )
                        .foregroundStyle(point.anomalyType == .spike ? Color.red : (point.anomalyType == .drop ? Color.cyan : Color.green))
                        .symbolSize(point.isAnomaly ? 150 : 50)
                    }
                    .chartYScale(domain: 0...130)
                    .frame(height: 300)
                    .padding()
                    .background(viewModel.isTimeFrozen ? Color.cyan.opacity(0.1) : Color.green.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    // YENİ VE KUSURSUZ TIKLAMA ALANI (HITBOX)
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            Rectangle().fill(Color.clear).contentShape(Rectangle())
                                .onTapGesture { location in
                                    // 1. Grafik alanının sınırlarını (Y ekseni sayıları hariç) net bir şekilde belirliyoruz
                                    let plotAreaRect = geometry[proxy.plotAreaFrame]
                                    
                                    // 2. Y ekseni sayılarının kapladığı pikselleri, tıkladığımız yerden çıkarıyoruz
                                    let tapX = location.x - plotAreaRect.origin.x
                                    
                                    // Sadece çerçevenin içine tıkladıysak işleme devam et
                                    guard tapX >= 0 && tapX <= plotAreaRect.width else { return }
                                    
                                    // 3. Hesaplanan pikseli oyun içindeki "Zaman" (Date) değerine çeviriyoruz
                                    if let date: Date = proxy.value(atX: tapX) {
                                        if let closestPoint = findClosestPoint(to: date) {
                                            withAnimation(.spring()) {
                                                viewModel.inspectNode(closestPoint)
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
                
                Spacer()
                
                // JOKER TUŞU (ZAMAN DONDURUCU)
                Button(action: {
                    withAnimation {
                        viewModel.usePowerUp()
                    }
                }) {
                    HStack {
                        Image(systemName: "snowflake")
                        Text("ZAMANI DONDUR (\(viewModel.powerUpsRemaining))")
                    }
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.powerUpsRemaining > 0 && !viewModel.isTimeFrozen ? Color.cyan.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(viewModel.powerUpsRemaining > 0 && !viewModel.isTimeFrozen ? .cyan : .gray)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(viewModel.powerUpsRemaining > 0 && !viewModel.isTimeFrozen ? Color.cyan : Color.gray, lineWidth: 1))
                }
                .disabled(viewModel.powerUpsRemaining == 0 || viewModel.isTimeFrozen || viewModel.isGameOver || viewModel.isVictory)
                .padding(.horizontal)
                .padding(.bottom, 20)
                
            }
            .blur(radius: viewModel.isGameOver || viewModel.isVictory ? 5 : 0)
            
            // OYUN SONU EKRANI
            if viewModel.isGameOver || viewModel.isVictory {
                VStack(spacing: 20) {
                    Text(viewModel.isVictory ? "SİSTEM KURTARILDI" : "SİSTEM ÇÖKTÜ")
                        .font(.system(size: 28, weight: .heavy, design: .monospaced))
                        .foregroundColor(viewModel.isVictory ? .green : .red)
                    
                    Text("Son Skor: \(viewModel.score)")
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        withAnimation { viewModel.startHackTrace(resetGame: true) }
                    }) {
                        Text("YENİDEN BAŞLAT")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .padding()
                            .background(Color.black)
                            .foregroundColor(viewModel.isVictory ? .green : .red)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(viewModel.isVictory ? Color.green : Color.red, lineWidth: 2))
                    }
                }
                .padding(40)
                .background(Color.black.opacity(0.9))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(viewModel.isVictory ? Color.green : Color.red, lineWidth: 2))
            }
        }
        .onAppear {
            viewModel.startHackTrace()
        }
    }
    
    // YENİ: Mobilde daha rahat tıklanabilmesi için toleransı 20 Saniyeye çıkardık!
    private func findClosestPoint(to date: Date) -> DataPoint? {
        let closest = viewModel.dataPoints.min(by: {
            abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date))
        })
        
        // Eğer en yakın nokta normalse (yeşilse), ama yakınlarda bir virüs varsa,
        // oyuncuya avantaj sağla ve virüsü vurduğunu varsay (Hitbox toleransı)
        if let closest = closest, !closest.isAnomaly {
            let nearbyAnomaly = viewModel.dataPoints.first { point in
                point.isAnomaly && abs(point.timestamp.timeIntervalSince(date)) <= 20.0 // 6'dan 20'ye çıktı!
            }
            if let nearbyAnomaly = nearbyAnomaly {
                return nearbyAnomaly
            }
        }
        return closest
    }
}

extension View {
    func blinkEffect(isActive: Bool) -> some View {
        self.modifier(ConditionalBlinkModifier(isActive: isActive))
    }
}

struct ConditionalBlinkModifier: ViewModifier {
    var isActive: Bool
    @State private var isBlinking = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive && isBlinking ? 0.2 : 1.0)
            .animation(isActive ? .easeInOut(duration: 0.5).repeatForever() : .default, value: isBlinking)
            .onChange(of: isActive) { oldValue, newValue in
                isBlinking = newValue
            }
    }
}
