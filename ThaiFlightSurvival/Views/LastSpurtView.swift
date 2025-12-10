import SwiftUI

struct LastSpurtView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var progressService: ProgressService
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @StateObject private var viewModel = QuizViewModel()
    
    @State private var questionCount = 0
    @State private var correctCount = 0
    @State private var showResult = false
    
    private let totalQuestions = 10
    
    var body: some View {
        ZStack {
            Color.themeBackground(colorScheme)
                .ignoresSafeArea()
            
            if showResult {
                resultView
            } else {
                quizContent
            }
        }
        .onAppear {
            viewModel.startLastSpurt()
            
            if settingsViewModel.autoPlayAudio {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.speakCurrentPhrase()
                }
            }
        }
    }
    
    // MARK: - クイズコンテンツ
    
    private var quizContent: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(Color.themePrimaryText(colorScheme))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("ラストスパート")
                        .font(.headline)
                        .foregroundColor(Color.themeGold(colorScheme))
                    
                    Text("\(questionCount + 1)/\(totalQuestions)")
                        .font(.subheadline)
                        .foregroundColor(Color.themeSecondaryText(colorScheme))
                }
                
                Spacer()
                
                Button(action: { viewModel.speakCurrentPhrase() }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(Color.themeAccent(colorScheme))
                }
            }
            .padding()
            
            // 進捗バー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.themeSecondaryText(colorScheme).opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.themeGold(colorScheme))
                        .frame(width: geometry.size.width * CGFloat(questionCount) / CGFloat(totalQuestions), height: 6)
                }
            }
            .frame(height: 6)
            .padding(.horizontal)
            
            Spacer()
            
            // 問題
            if let quizState = viewModel.quizState {
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
                .padding(.horizontal)
                
                Spacer()
                
                // 選択肢
                VStack(spacing: 12) {
                    ForEach(quizState.optionItems, id: \.self) { optionItem in
                        Button(action: {
                            if !quizState.isAnswered {
                                handleAnswer(optionItem.text, quizState: quizState)
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
                .padding(.horizontal)
                
                // 次へボタン
                if quizState.isAnswered {
                    Button(action: nextQuestion) {
                        Text(questionCount + 1 >= totalQuestions ? "結果を見る" : "次へ")
                            .primaryButtonStyle(colorScheme)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    // MARK: - 結果画面
    
    private var resultView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // スコア
            ZStack {
                Circle()
                    .stroke(Color.themeSecondaryText(colorScheme).opacity(0.2), lineWidth: 12)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: CGFloat(correctCount) / CGFloat(totalQuestions))
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(correctCount)/\(totalQuestions)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.themePrimaryText(colorScheme))
                    
                    Text("正解")
                        .font(.subheadline)
                        .foregroundColor(Color.themeSecondaryText(colorScheme))
                }
            }
            
            // メッセージ
            VStack(spacing: 8) {
                Text(resultTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.themePrimaryText(colorScheme))
                
                Text(resultMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.themeSecondaryText(colorScheme))
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // ボタン
            VStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("ホームに戻る")
                        .primaryButtonStyle(colorScheme)
                }
                
                Button(action: retry) {
                    Text("もう一度挑戦")
                        .font(.headline)
                        .foregroundColor(Color.themeAccent(colorScheme))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - ヘルパー
    
    private func handleAnswer(_ answer: String, quizState: QuizState) {
        HapticService.shared.playTapFeedback()
        viewModel.selectAnswer(answer, progressService: progressService, settingsViewModel: settingsViewModel)
        
        if answer == quizState.correctAnswer {
            correctCount += 1
        }
    }
    
    private func nextQuestion() {
        questionCount += 1
        
        if questionCount >= totalQuestions {
            showResult = true
        } else {
            viewModel.proceedToNext(progressService: progressService)
            
            if settingsViewModel.autoPlayAudio {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.speakCurrentPhrase()
                }
            }
        }
    }
    
    private func retry() {
        questionCount = 0
        correctCount = 0
        showResult = false
        viewModel.startLastSpurt()
    }
    
    private var scoreColor: Color {
        let percentage = Double(correctCount) / Double(totalQuestions)
        if percentage >= 0.8 {
            return Color.themeCorrect(colorScheme)
        } else if percentage >= 0.5 {
            return Color.themeGold(colorScheme)
        } else {
            return Color.themeIncorrect(colorScheme)
        }
    }
    
    private var resultTitle: String {
        let percentage = Double(correctCount) / Double(totalQuestions)
        if percentage >= 0.8 {
            return "🎉 すばらしい！"
        } else if percentage >= 0.5 {
            return "👍 いい調子！"
        } else {
            return "💪 もう少し！"
        }
    }
    
    private var resultMessage: String {
        let percentage = Double(correctCount) / Double(totalQuestions)
        if percentage >= 0.8 {
            return "ホテルまでは余裕で行けそう！\nタイ旅行を楽しんで！"
        } else if percentage >= 0.5 {
            return "基本はOK！\nもう少し復習すると安心。"
        } else {
            return "もう一度チャレンジしてみよう！\n繰り返しが大切！"
        }
    }
}

#Preview {
    LastSpurtView()
        .environmentObject(SettingsViewModel())
        .environmentObject(ProgressService())
}
