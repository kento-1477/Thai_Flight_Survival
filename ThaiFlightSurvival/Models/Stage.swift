import Foundation

/// ステージの状態を表すモデル
struct Stage: Identifiable, Hashable {
    
    static func == (lhs: Stage, rhs: Stage) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: String
    let category: StageCategory
    var phrases: [Phrase]
    var isCleared: Bool
    var currentStreak: Int
    
    init(category: StageCategory, phrases: [Phrase], isCleared: Bool = false, currentStreak: Int = 0) {
        self.id = category.rawValue
        self.category = category
        self.phrases = phrases
        self.isCleared = isCleared
        self.currentStreak = currentStreak
    }
    
    var displayName: String {
        category.displayName
    }
    
    var description: String {
        category.description
    }
    
    var iconName: String {
        category.iconName
    }
    
    var phraseCount: Int {
        phrases.count
    }
    
    /// クリアに必要な連続正解数
    static let requiredStreak = 5
    
    /// 残りの正解数
    var remainingToComplete: Int {
        max(0, Stage.requiredStreak - currentStreak)
    }
}
