import Foundation
import SwiftUI

/// クイズ画面のViewModel
class QuizViewModel: ObservableObject {
    @Published var quizState: QuizState?
    @Published var mode: QuizMode = .reception
    @Published var showClearScreen = false
    @Published var isLastSpurtMode = false
    
    private var allPhrases: [Phrase] = []
    private var currentStageId: String = ""
    private var usedPhraseIds: Set<Int> = []
    
    let audioService = AudioService.shared
    let hapticService = HapticService.shared
    
    // MARK: - ステージモード
    
    func startStage(_ stage: Stage, progressService: ProgressService) {
        isLastSpurtMode = false
        currentStageId = stage.id
        allPhrases = stage.phrases
        usedPhraseIds = []
        
        let streak = progressService.getCurrentStreak(for: stage.id)
        generateNextQuestion(streakCount: streak)
    }
    
    // MARK: - ラストスパートモード
    
    func startLastSpurt() {
        isLastSpurtMode = true
        currentStageId = "lastspurt"
        allPhrases = PhraseDataService.shared.getCorePhrases()
        usedPhraseIds = []
        
        generateNextQuestion(streakCount: 0)
    }
    
    // MARK: - クイズロジック
    
    func generateNextQuestion(streakCount: Int) {
        guard !allPhrases.isEmpty else { return }
        
        // まだ出題していないフレーズを優先
        var availablePhrases = allPhrases.filter { !usedPhraseIds.contains($0.id) }
        
        // 全て出題済みの場合はリセット
        if availablePhrases.isEmpty {
            usedPhraseIds = []
            availablePhrases = allPhrases
        }
        
        guard let randomPhrase = availablePhrases.randomElement() else { return }
        usedPhraseIds.insert(randomPhrase.id)
        
        quizState = QuizState(
            phrase: randomPhrase,
            allPhrases: allPhrases,
            mode: mode,
            streakCount: streakCount
        )
    }
    
    func selectAnswer(_ answer: String, progressService: ProgressService, settingsViewModel: SettingsViewModel) {
        guard var state = quizState else { return }
        state.selectAnswer(answer)
        quizState = state
        
        let isCorrect = state.isCorrect ?? false
        
        // フィードバック
        if settingsViewModel.hapticEnabled {
            if isCorrect {
                hapticService.playCorrectFeedback()
            } else {
                hapticService.playIncorrectFeedback()
            }
        }
        
        if settingsViewModel.soundEffectsEnabled {
            if isCorrect {
                audioService.playCorrectSound()
            } else {
                audioService.playIncorrectSound()
            }
        }
        
        // 音声自動再生
        if settingsViewModel.autoPlayAudio {
            audioService.speak(state.currentPhrase.speechText)
        }
        
        // ラストスパートモード以外で連続正解を更新
        if !isLastSpurtMode {
            if isCorrect {
                let newStreak = progressService.incrementStreak(for: currentStageId)
                
                // 5問連続正解でクリア
                if newStreak >= Stage.requiredStreak {
                    progressService.markStageAsCleared(currentStageId)
                    showClearScreen = true
                }
            } else {
                // 不正解でリセット
                progressService.resetStreak(for: currentStageId)
            }
        }
    }
    
    func proceedToNext(progressService: ProgressService) {
        guard let currentState = quizState else { return }
        
        let streak = progressService.getCurrentStreak(for: currentStageId)
        generateNextQuestion(streakCount: streak)
    }
    
    func switchMode(_ newMode: QuizMode, progressService: ProgressService) {
        mode = newMode
        let streak = progressService.getCurrentStreak(for: currentStageId)
        generateNextQuestion(streakCount: streak)
    }
    
    func speakCurrentPhrase() {
        guard let phrase = quizState?.currentPhrase else { return }
        audioService.speak(phrase.speechText)
    }
    
    var currentStreak: Int {
        quizState?.streakCount ?? 0
    }
    
    var remainingToComplete: Int {
        max(0, Stage.requiredStreak - currentStreak)
    }
}
