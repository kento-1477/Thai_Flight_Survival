import Foundation
import SwiftUI

/// ホーム画面のViewModel
class HomeViewModel: ObservableObject {
    @Published var stages: [Stage] = []
    
    private let phraseDataService = PhraseDataService.shared
    
    init() {
        loadStages()
    }
    
    func loadStages() {
        stages = phraseDataService.getAllStages()
    }
    
    func updateStageProgress(progressService: ProgressService) {
        stages = stages.map { stage in
            var updatedStage = stage
            updatedStage.isCleared = progressService.isStageCleared(stage.id)
            updatedStage.currentStreak = progressService.getCurrentStreak(for: stage.id)
            return updatedStage
        }
    }
    
    func getStage(for category: StageCategory) -> Stage? {
        return stages.first { $0.category == category }
    }
    
    var clearedStageCount: Int {
        stages.filter { $0.isCleared }.count
    }
    
    var totalStageCount: Int {
        stages.count
    }
    
    var hasCorePhrases: Bool {
        !phraseDataService.getCorePhrases().isEmpty
    }
}
