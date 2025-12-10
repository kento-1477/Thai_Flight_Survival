import SwiftUI

struct QuizView: View {
    let stage: Stage
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var progressService: ProgressService
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @StateObject private var viewModel = QuizViewModel()
    @State private var showClear = false
    
    var body: some View {
        ZStack {
            Color.themeBackground(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ヘッダー
                headerSection
                
                // モード切替
                modeToggle
                
                Spacer()
                
                // 問題
                if let quizState = viewModel.quizState {
                    questionSection(quizState)
                    
                    Spacer()
                    
                    // 選択肢
                    optionsSection(quizState)
                    
                    // 次へボタン
                    if quizState.isAnswered {
                        nextButton
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startStage(stage, progressService: progressService)
            
            // 音声自動再生
            if settingsViewModel.autoPlayAudio {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.speakCurrentPhrase()
                }
            }
        }
        .onChange(of: viewModel.showClearScreen) { newValue in
            if newValue {
                showClear = true
                viewModel.showClearScreen = false
            }
        }
        .fullScreenCover(isPresented: $showClear) {
            ClearView(stage: stage, onContinue: {
                showClear = false
                dismiss()
            }, onRetry: {
                showClear = false
                viewModel.startStage(stage, progressService: progressService)
            })
        }
    }
    
    // MARK: - ヘッダー
    
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(Color.themePrimaryText(colorScheme))
            }
            
            Spacer()
            
            // 進捗表示
            VStack(spacing: 4) {
                Text(stage.displayName)
                    .font(.headline)
                    .foregroundColor(Color.themePrimaryText(colorScheme))
                
                HStack(spacing: 4) {
                    ForEach(0..<Stage.requiredStreak, id: \.self) { index in
                        Circle()
                            .fill(index < progressService.getCurrentStreak(for: stage.id) 
                                  ? Color.themeAccent(colorScheme) 
                                  : Color.themeSecondaryText(colorScheme).opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            
            Spacer()
            
            // 音声ボタン
            Button(action: { viewModel.speakCurrentPhrase() }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .foregroundColor(Color.themeAccent(colorScheme))
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - モード切替
    
    private var modeToggle: some View {
        Picker("モード", selection: $viewModel.mode) {
            ForEach(QuizMode.allCases, id: \.self) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 8)
        .onChange(of: viewModel.mode) { newMode in
            viewModel.switchMode(newMode, progressService: progressService)
        }
    }
    
    // MARK: - 問題
    
    private func questionSection(_ quizState: QuizState) -> some View {
        VStack(spacing: 12) {
            Text(quizState.mode.questionLabel)
                .font(.subheadline)
                .foregroundColor(Color.themeSecondaryText(colorScheme))
            
            Text(quizState.questionText)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.themePrimaryText(colorScheme))
                .multilineTextAlignment(.center)
            
            if let reading = quizState.readingText {
                Text(reading)
                    .font(.title3)
                    .foregroundColor(Color.themeSecondaryText(colorScheme))
            }
        }
        .padding()
        .cardStyle(colorScheme)
    }
    
    // MARK: - 選択肢
    
    private func optionsSection(_ quizState: QuizState) -> some View {
        VStack(spacing: 12) {
            ForEach(quizState.optionItems, id: \.self) { optionItem in
                Button(action: {
                    if !quizState.isAnswered {
                        HapticService.shared.playTapFeedback()
                        viewModel.selectAnswer(optionItem.text, progressService: progressService, settingsViewModel: settingsViewModel)
                    }
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(optionItem.text)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        if let reading = optionItem.reading {
                            Text(reading)
                                .font(.caption)
                                .foregroundColor(Color.themeSecondaryText(colorScheme))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .optionButtonStyle(
                        colorScheme,
                        isSelected: quizState.selectedAnswer == optionItem.text,
                        isCorrect: quizState.isAnswered ? (optionItem.text == quizState.correctAnswer) : nil
                    )
                }
                .disabled(quizState.isAnswered)
            }
        }
    }
    
    // MARK: - 次へボタン
    
    private var nextButton: some View {
        Button(action: {
            viewModel.proceedToNext(progressService: progressService)
            
            // 音声自動再生
            if settingsViewModel.autoPlayAudio {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.speakCurrentPhrase()
                }
            }
        }) {
            Text("次の問題へ")
                .primaryButtonStyle(colorScheme)
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
}

#Preview {
    QuizView(stage: Stage(
        category: .airport,
        phrases: [
            Phrase(id: 1, category: "airport", thai: "สวัสดี", reading: "サワディー", meaning: "こんにちは", note: nil, isCore: true),
            Phrase(id: 2, category: "airport", thai: "ขอบคุณ", reading: "コップクン", meaning: "ありがとう", note: nil, isCore: true),
            Phrase(id: 3, category: "airport", thai: "ห้องน้ำ", reading: "ホンナーム", meaning: "トイレ", note: nil, isCore: false),
            Phrase(id: 4, category: "airport", thai: "ที่ไหน", reading: "ティーナイ", meaning: "どこ？", note: nil, isCore: false),
        ]
    ))
    .environmentObject(SettingsViewModel())
    .environmentObject(ProgressService())
}
