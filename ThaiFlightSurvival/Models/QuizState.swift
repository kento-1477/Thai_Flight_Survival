import Foundation

/// クイズの出題モード
enum QuizMode: String, CaseIterable {
    case reception = "reception"   // タイ語 → 日本語（受信モード）
    case production = "production" // 日本語 → タイ語（発信モード）
    
    var displayName: String {
        switch self {
        case .reception: return "聞いて理解"
        case .production: return "話して伝える"
        }
    }
    
    var questionLabel: String {
        switch self {
        case .reception: return "このタイ語の意味は？"
        case .production: return "これをタイ語で言うと？"
        }
    }
}

/// クイズの状態
struct QuizState {
    var currentPhrase: Phrase
    var options: [String]
    var correctAnswer: String
    var selectedAnswer: String?
    var isAnswered: Bool
    var isCorrect: Bool?
    var mode: QuizMode
    var streakCount: Int
    
    init(phrase: Phrase, allPhrases: [Phrase], mode: QuizMode, streakCount: Int = 0) {
        self.currentPhrase = phrase
        self.mode = mode
        self.streakCount = streakCount
        self.isAnswered = false
        
        // 正解と選択肢を生成
        switch mode {
        case .reception:
            // タイ語 → 日本語：日本語の選択肢を生成
            self.correctAnswer = phrase.meaning
            let wrongAnswers = allPhrases
                .filter { $0.id != phrase.id }
                .shuffled()
                .prefix(3)
                .map { $0.meaning }
            self.options = ([correctAnswer] + wrongAnswers).shuffled()
            
        case .production:
            // 日本語 → タイ語：タイ語の選択肢を生成
            self.correctAnswer = phrase.thai
            let wrongAnswers = allPhrases
                .filter { $0.id != phrase.id }
                .shuffled()
                .prefix(3)
                .map { $0.thai }
            self.options = ([correctAnswer] + wrongAnswers).shuffled()
        }
    }
    
    /// 問題文を取得
    var questionText: String {
        switch mode {
        case .reception:
            return currentPhrase.thai
        case .production:
            return currentPhrase.meaning
        }
    }
    
    /// 読み仮名を取得（受信モード時のみ表示）
    var readingText: String? {
        switch mode {
        case .reception:
            return currentPhrase.reading
        case .production:
            return nil
        }
    }
    
    mutating func selectAnswer(_ answer: String) {
        guard !isAnswered else { return }
        selectedAnswer = answer
        isAnswered = true
        isCorrect = answer == correctAnswer
    }
}
