import Foundation
import SwiftUI

/// ユーザーの進捗を管理するサービス
class ProgressService: ObservableObject {
    @Published var clearedStageIds: Set<String> = []
    @Published var currentStreaks: [String: Int] = [:]
    @Published var hasCompletedOnboarding: Bool = false
    
    private let clearedStagesKey = "clearedStageIds"
    private let currentStreaksKey = "currentStreaks"
    private let onboardingCompletedKey = "hasCompletedOnboarding"
    
    init() {
        loadProgress()
    }
    
    // MARK: - オンボーディング
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
    }
    
    // MARK: - ステージクリア
    
    func isStageCleared(_ stageId: String) -> Bool {
        return clearedStageIds.contains(stageId)
    }
    
    func markStageAsCleared(_ stageId: String) {
        clearedStageIds.insert(stageId)
        currentStreaks[stageId] = 0
        saveProgress()
    }
    
    // MARK: - 連続正解カウント
    
    func getCurrentStreak(for stageId: String) -> Int {
        return currentStreaks[stageId] ?? 0
    }
    
    func incrementStreak(for stageId: String) -> Int {
        let newStreak = (currentStreaks[stageId] ?? 0) + 1
        currentStreaks[stageId] = newStreak
        saveProgress()
        return newStreak
    }
    
    func resetStreak(for stageId: String) {
        currentStreaks[stageId] = 0
        saveProgress()
    }
    
    // MARK: - 進捗計算
    
    var clearedStageCount: Int {
        return clearedStageIds.count
    }
    
    var totalStageCount: Int {
        return StageCategory.allCases.count
    }
    
    var progressPercentage: Double {
        guard totalStageCount > 0 else { return 0 }
        return Double(clearedStageCount) / Double(totalStageCount)
    }
    
    // MARK: - 保存・読み込み
    
    private func saveProgress() {
        UserDefaults.standard.set(Array(clearedStageIds), forKey: clearedStagesKey)
        UserDefaults.standard.set(currentStreaks, forKey: currentStreaksKey)
    }
    
    private func loadProgress() {
        if let clearedIds = UserDefaults.standard.array(forKey: clearedStagesKey) as? [String] {
            clearedStageIds = Set(clearedIds)
        }
        if let streaks = UserDefaults.standard.dictionary(forKey: currentStreaksKey) as? [String: Int] {
            currentStreaks = streaks
        }
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
    }
    
    /// デバッグ用：進捗をリセット
    func resetAllProgress() {
        clearedStageIds = []
        currentStreaks = [:]
        hasCompletedOnboarding = false
        UserDefaults.standard.removeObject(forKey: clearedStagesKey)
        UserDefaults.standard.removeObject(forKey: currentStreaksKey)
        UserDefaults.standard.removeObject(forKey: onboardingCompletedKey)
    }
}
