//
//  GameView.swift
//  Data Heist
//
//  Created by BERKAY TURAN on 15.04.2026.
//


import SwiftUI
import Charts
import SwiftData

struct GameView: View {
    @State private var viewModel = GameViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext // Veritabanı bağlamını alıyoruz
    
    var startingLevel: Int = 1
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 15) {
                // 1. IP TESPİT BARI
                VStack(spacing: 2) {
                    HStack {
                        Text("IP TESPİT RİSKİ").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(viewModel.ipDetection > 75 ? .red : .gray)
                        Spacer()
                        Text("%\(Int(viewModel.ipDetection))").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(viewModel.ipDetection > 75 ? .red : .gray)
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle().frame(width: geometry.size.width, height: 8).opacity(0.3).foregroundColor(.gray)
                            Rectangle().frame(width: min(CGFloat(viewModel.ipDetection / 100.0) * geometry.size.width, geometry.size.width), height: 8)
                                .foregroundColor(viewModel.ipDetection > 75 ? .red : (viewModel.ipDetection > 50 ? .orange : .green)).animation(.linear, value: viewModel.ipDetection)
                        }.cornerRadius(4)
                    }.frame(height: 8)
                }.padding(.horizontal).padding(.top, 5)
                
                // 2. ÜST BİLGİ PANELİ
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("SEVİYE: \(viewModel.currentLevel)").font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(.gray)
                        Text("SKOR: \(viewModel.score)").font(.system(size: 20, weight: .bold, design: .monospaced)).foregroundColor(.green)
                    }
                    Spacer()
                    if viewModel.combo > 1 {
                        Text("x\(viewModel.combo)").font(.system(size: 28, weight: .black, design: .monospaced)).foregroundColor(.orange).glow(color: .orange, radius: 5).transition(.scale)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("SÜRE: \(viewModel.timeLeft) SN").font(.system(size: 20, weight: .bold, design: .monospaced)).foregroundColor(viewModel.isTimeFrozen ? .cyan : (viewModel.timeLeft <= 5 ? .red : .green)).blinkEffect(isActive: viewModel.timeLeft <= 5 && !viewModel.isGameOver && !viewModel.isVictory && !viewModel.isTimeFrozen)
                    }
                }.padding(.horizontal)
                
                // 3. TERMİNAL MESAJI
                Text(viewModel.terminalMessage).font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(viewModel.isTimeFrozen ? .cyan : (viewModel.terminalMessage.contains("HATA") || viewModel.terminalMessage.contains("POLİS") || viewModel.isGameOver ? .red : .green)).frame(maxWidth: .infinity, alignment: .leading).padding().background(Color.gray.opacity(0.1)).cornerRadius(8).padding(.horizontal)
                
                // 4. GRAFİK ALANI
                if !viewModel.dataPoints.isEmpty {
                    Chart(viewModel.dataPoints) { point in
                        LineMark(x: .value("Zaman", point.timestamp), y: .value("Veri Yükü", point.value)).foregroundStyle(Color.green.opacity(0.8)).lineStyle(StrokeStyle(lineWidth: 2))
                        PointMark(x: .value("Zaman", point.timestamp), y: .value("Veri Yükü", point.value)).foregroundStyle(point.anomalyType == .spike ? Color.red : (point.anomalyType == .drop ? Color.cyan : Color.green)).symbolSize(point.isAnomaly ? 150 : 50)
                    }
                    .chartYScale(domain: 0...130).frame(height: 300).padding().background(Color.green.opacity(0.05)).cornerRadius(12).padding(.horizontal)
                    .chartOverlay { proxy in
                        Color.clear.contentShape(Rectangle()).onTapGesture { location in
                            if let date: Date = proxy.value(atX: location.x) {
                                if let closestPoint = findClosestPoint(to: date) {
                                    withAnimation(.spring()) { viewModel.inspectNode(closestPoint) }
                                }
                            }
                        }
                    }
                }
                Spacer()
                
                // 5. JOKER TUŞU
                Button(action: { withAnimation { viewModel.usePowerUp() } }) {
                    HStack { Image(systemName: "snowflake"); Text("ZAMANI DONDUR (\(viewModel.powerUpsRemaining))") }
                    .font(.system(size: 16, weight: .bold, design: .monospaced)).padding().frame(maxWidth: .infinity).background(viewModel.powerUpsRemaining > 0 && !viewModel.isTimeFrozen ? Color.cyan.opacity(0.2) : Color.gray.opacity(0.1)).foregroundColor(viewModel.powerUpsRemaining > 0 && !viewModel.isTimeFrozen ? .cyan : .gray).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(viewModel.powerUpsRemaining > 0 && !viewModel.isTimeFrozen ? Color.cyan : Color.gray, lineWidth: 1))
                }.disabled(viewModel.powerUpsRemaining == 0 || viewModel.isTimeFrozen || viewModel.isGameOver || viewModel.isVictory).padding(.horizontal).padding(.bottom, 10)
            }
            .blur(radius: viewModel.isGameOver || viewModel.isVictory ? 5 : 0)
            
            // 6. KONTROL PANELİ
            if viewModel.isGameOver || viewModel.isVictory {
                VStack(spacing: 20) {
                    Text(viewModel.isVictory ? "BÖLÜM TEMİZLENDİ" : "SİSTEM ÇÖKTÜ").font(.system(size: 28, weight: .heavy, design: .monospaced)).foregroundColor(viewModel.isVictory ? .green : .red)
                    Text("Kazanılan Siber Coin: ₿\(viewModel.cyberCoinsEarned)").font(.system(size: 16, design: .monospaced)).foregroundColor(.yellow)
                    
                    HStack(spacing: 10) {
                        // 1. MENÜ BUTONU: Zincirleme kapatma ile en başa döner.
                        Button(action: {
                            dismiss() // Önce mevcut oyun ekranını (modalı) kapat
                            
                            // Ekran kapanma animasyonuna zaman tanıyıp, alttaki haritaya "Sen de kapan" diyoruz.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                NotificationCenter.default.post(name: NSNotification.Name("GoToRoot"), object: nil)
                            }
                        }) {
                            Text("MENÜ")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // GameView.swift içindeki HARİTA butonu
                        Button(action: {
                            // 1. Önce grafikleri ve zamanlayıcıyı durdur (Grafik motorunu rahatlat)
                            viewModel.startHackTrace(level: viewModel.currentLevel, resetGame: false)
                            
                            // 2. Çok kısa bir gecikmeyle ekranı kapat (CA Event hatasını önler)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                dismiss()
                            }
                        }) {
                            Text("HARİTA")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.3))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            withAnimation {
                                if viewModel.isVictory && viewModel.currentLevel < 20 {
                                    viewModel.startHackTrace(level: viewModel.currentLevel + 1, resetGame: false)
                                } else {
                                    viewModel.startHackTrace(level: viewModel.currentLevel, resetGame: true)
                                }
                            }
                        }) {
                            Text(viewModel.isVictory ? "SONRAKİ" : "TEKRAR").font(.system(size: 12, weight: .bold, design: .monospaced)).padding(.vertical, 12).frame(maxWidth: .infinity).background(viewModel.isVictory ? Color.green.opacity(0.3) : Color.red.opacity(0.3)).foregroundColor(viewModel.isVictory ? .green : .red).cornerRadius(8)
                        }
                    }
                }.padding(25).background(Color.black.opacity(0.95)).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(viewModel.isVictory ? Color.green : Color.red, lineWidth: 2)).padding(.horizontal, 15)
            }
        }
        .onAppear {
            // KRİTİK: ViewModel'e veritabanı bağlamını veriyoruz
            viewModel.modelContext = modelContext
            viewModel.startHackTrace(level: startingLevel)
        }
    }
    
    private func findClosestPoint(to date: Date) -> DataPoint? {
        let closest = viewModel.dataPoints.min(by: { abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date)) })
        if let closest = closest, !closest.isAnomaly {
            let nearbyAnomaly = viewModel.dataPoints.first { point in point.isAnomaly && abs(point.timestamp.timeIntervalSince(date)) <= 20.0 }
            if let nearbyAnomaly = nearbyAnomaly { return nearbyAnomaly }
        }
        return closest
    }
}

// Marker ve Modifier'lar
struct ConditionalBlinkModifier: ViewModifier {
    var isActive: Bool
    @State private var isBlinking = false
    func body(content: Content) -> some View {
        content.opacity(isActive && isBlinking ? 0.2 : 1.0).animation(isActive ? .easeInOut(duration: 0.5).repeatForever() : .default, value: isBlinking)
            .onChange(of: isActive) { _, newValue in isBlinking = newValue }
    }
}
extension View { func blinkEffect(isActive: Bool) -> some View { self.modifier(ConditionalBlinkModifier(isActive: isActive)) } }
