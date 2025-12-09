import SwiftUI

struct HomeView: View {
    @EnvironmentObject var progressService: ProgressService
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSettings = false
    @State private var showLastSpurt = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground(colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // ヘッダー
                        headerSection
                        
                        // ラストスパートボタン
                        lastSpurtButton
                        
                        // ステージ一覧
                        stagesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("タイ語サバイバル")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color.themeAccent(colorScheme))
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showLastSpurt) {
                LastSpurtView()
            }
            .onAppear {
                viewModel.updateStageProgress(progressService: progressService)
            }
        }
    }
    
    // MARK: - ヘッダー
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // 進捗バー
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("全体の進捗")
                        .font(.subheadline)
                        .foregroundColor(Color.themeSecondaryText(colorScheme))
                    
                    Spacer()
                    
                    Text("\(progressService.clearedStageCount)/\(progressService.totalStageCount) ステージ")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.themePrimaryText(colorScheme))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.themeSecondaryText(colorScheme).opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.themeAccent(colorScheme))
                            .frame(width: geometry.size.width * progressService.progressPercentage, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .cardStyle(colorScheme)
        }
    }
    
    // MARK: - ラストスパートボタン
    
    private var lastSpurtButton: some View {
        Button(action: { showLastSpurt = true }) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("着陸前ラストスパート")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("最重要フレーズだけを一気に復習")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.themeGold(colorScheme),
                        Color.themeGold(colorScheme).opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    // MARK: - ステージ一覧
    
    private var stagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("シーン別ステージ")
                .font(.headline)
                .foregroundColor(Color.themePrimaryText(colorScheme))
            
            ForEach(viewModel.stages) { stage in
                NavigationLink(destination: QuizView(stage: stage)) {
                    StageCardView(stage: stage, progressService: progressService)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - ステージカード

struct StageCardView: View {
    let stage: Stage
    @ObservedObject var progressService: ProgressService
    @Environment(\.colorScheme) var colorScheme
    
    private var isCleared: Bool {
        progressService.isStageCleared(stage.id)
    }
    
    private var currentStreak: Int {
        progressService.getCurrentStreak(for: stage.id)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // アイコン
            ZStack {
                Circle()
                    .fill(isCleared ? Color.themeCorrect(colorScheme) : Color.themeAccent(colorScheme).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                if isCleared {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: stage.iconName)
                        .font(.title3)
                        .foregroundColor(Color.themeAccent(colorScheme))
                }
            }
            
            // テキスト
            VStack(alignment: .leading, spacing: 4) {
                Text(stage.displayName)
                    .font(.headline)
                    .foregroundColor(Color.themePrimaryText(colorScheme))
                
                Text(stage.description)
                    .font(.caption)
                    .foregroundColor(Color.themeSecondaryText(colorScheme))
            }
            
            Spacer()
            
            // 進捗
            VStack(alignment: .trailing, spacing: 2) {
                if isCleared {
                    Text("クリア済み")
                        .font(.caption)
                        .foregroundColor(Color.themeCorrect(colorScheme))
                } else if currentStreak > 0 {
                    Text("あと\(Stage.requiredStreak - currentStreak)問")
                        .font(.caption)
                        .foregroundColor(Color.themeAccent(colorScheme))
                }
                
                Text("\(stage.phraseCount)フレーズ")
                    .font(.caption2)
                    .foregroundColor(Color.themeSecondaryText(colorScheme))
            }
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundColor(Color.themeSecondaryText(colorScheme))
        }
        .padding()
        .cardStyle(colorScheme)
    }
}

#Preview {
    HomeView()
        .environmentObject(SettingsViewModel())
        .environmentObject(ProgressService())
}
