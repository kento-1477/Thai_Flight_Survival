import SwiftUI

struct StageDetailView: View {
    let stage: Stage
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var progressService: ProgressService
    
    @State private var showQuiz = false
    
    var body: some View {
        ZStack {
            Color.themeBackground(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // アイコン
                ZStack {
                    Circle()
                        .fill(Color.themeAccent(colorScheme).opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: stage.iconName)
                        .font(.system(size: 50))
                        .foregroundColor(Color.themeAccent(colorScheme))
                }
                
                // タイトル
                Text(stage.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.themePrimaryText(colorScheme))
                
                // 説明
                Text(stage.description)
                    .font(.body)
                    .foregroundColor(Color.themeSecondaryText(colorScheme))
                
                // 情報カード
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("フレーズ数")
                                .font(.caption)
                                .foregroundColor(Color.themeSecondaryText(colorScheme))
                            Text("\(stage.phraseCount)個")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.themePrimaryText(colorScheme))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("クリア条件")
                                .font(.caption)
                                .foregroundColor(Color.themeSecondaryText(colorScheme))
                            Text("\(Stage.requiredStreak)問連続正解")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.themePrimaryText(colorScheme))
                        }
                    }
                    
                    if progressService.getCurrentStreak(for: stage.id) > 0 {
                        Divider()
                        
                        HStack {
                            Text("現在の連続正解数")
                                .font(.caption)
                                .foregroundColor(Color.themeSecondaryText(colorScheme))
                            Spacer()
                            Text("\(progressService.getCurrentStreak(for: stage.id))問")
                                .font(.headline)
                                .foregroundColor(Color.themeAccent(colorScheme))
                        }
                    }
                }
                .padding()
                .cardStyle(colorScheme)
                .padding(.horizontal)
                
                Spacer()
                
                // スタートボタン
                Button(action: { showQuiz = true }) {
                    Text(progressService.isStageCleared(stage.id) ? "もう一度挑戦" : "スタート")
                        .primaryButtonStyle(colorScheme)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showQuiz) {
            QuizView(stage: stage)
        }
    }
}

#Preview {
    NavigationStack {
        StageDetailView(stage: Stage(
            category: .airport,
            phrases: []
        ))
        .environmentObject(SettingsViewModel())
        .environmentObject(ProgressService())
    }
}
