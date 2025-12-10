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

/// 選択肢の情報（タイ語 + 読み仮名）
struct OptionItem: Hashable {
    let text: String      // メインテキスト（タイ語 or 日本語）
    let reading: String?  // 読み仮名（発信モード時のみ）
    
    var displayText: String {
        if let reading = reading {
            return "\(text)\n\(reading)"
        }
        return text
    }
}

/// クイズの状態
struct QuizState {
    var currentPhrase: Phrase
    var optionItems: [OptionItem]  // 選択肢（読み仮名付き）
    var correctAnswer: String
    var selectedAnswer: String?
    var isAnswered: Bool
    var isCorrect: Bool?
    var mode: QuizMode
    var streakCount: Int
    
    /// 選択肢のテキスト配列（互換性のため）
    var options: [String] {
        optionItems.map { $0.text }
    }
    
    init(phrase: Phrase, allPhrases: [Phrase], mode: QuizMode, streakCount: Int = 0) {
        self.currentPhrase = phrase
        self.mode = mode
        self.streakCount = streakCount
        self.isAnswered = false
        
        // 正解と選択肢を生成
        switch mode {
        case .reception:
            // タイ語 → 日本語：日本語の選択肢を生成（読み仮名なし）
            self.correctAnswer = phrase.meaning
            let correctOption = OptionItem(text: phrase.meaning, reading: nil)
            let wrongOptions = allPhrases
                .filter { $0.id != phrase.id }
                .shuffled()
                .prefix(3)
                .map { OptionItem(text: $0.meaning, reading: nil) }
            self.optionItems = ([correctOption] + wrongOptions).shuffled()
            
        case .production:
            // 日本語 → タイ語：タイ語の選択肢を生成（読み仮名付き）
            self.correctAnswer = phrase.thai
            let correctOption = OptionItem(text: phrase.thai, reading: phrase.reading)
            let wrongOptions = allPhrases
                .filter { $0.id != phrase.id }
                .shuffled()
                .prefix(3)
                .map { OptionItem(text: $0.thai, reading: $0.reading) }
            self.optionItems = ([correctOption] + wrongOptions).shuffled()
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

