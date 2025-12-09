import SwiftUI

struct ClearView: View {
    let stage: Stage
    let onContinue: () -> Void
    let onRetry: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Color.themeBackground(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // クリアアイコン
                ZStack {
                    Circle()
                        .fill(Color.themeCorrect(colorScheme).opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.themeCorrect(colorScheme))
                        .scaleEffect(showConfetti ? 1.0 : 0.5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showConfetti)
                }
                
                // メッセージ
                VStack(spacing: 12) {
                    Text("🎉 ステージクリア！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.themePrimaryText(colorScheme))
                    
                    Text(stage.displayName)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.themeAccent(colorScheme))
                    
                    Text(clearMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.themeSecondaryText(colorScheme))
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // ボタン
                VStack(spacing: 12) {
                    Button(action: onContinue) {
                        Text("次のシーンへ進む")
                            .primaryButtonStyle(colorScheme)
                    }
                    
                    Button(action: onRetry) {
                        Text("このシーンをもう一度")
                            .font(.headline)
                            .foregroundColor(Color.themeAccent(colorScheme))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.themeAccent(colorScheme), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showConfetti = true
                HapticService.shared.playCorrectFeedback()
            }
        }
    }
    
    private var clearMessage: String {
        switch stage.category {
        case .airport:
            return "空港での基本フレーズはバッチリ！\n入国審査も怖くない！"
        case .transport:
            return "タクシーでの移動もスムーズにできそう！\nホテルまで安心です。"
        case .hotel:
            return "チェックインもこれで安心！\n快適なステイを楽しんで！"
        case .food:
            return "美味しいタイ料理を楽しもう！\nパクチー抜きもバッチリ！"
        case .basic:
            return "基本のあいさつと緊急時の対応もOK！\nタイ旅行を楽しんで！"
        }
    }
}

#Preview {
    ClearView(
        stage: Stage(category: .airport, phrases: []),
        onContinue: {},
        onRetry: {}
    )
}
