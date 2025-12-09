import Foundation

/// フレーズデータをJSONから読み込むサービス
class PhraseDataService {
    static let shared = PhraseDataService()
    
    private var phrases: [Phrase] = []
    
    private init() {
        loadPhrases()
    }
    
    private func loadPhrases() {
        guard let url = Bundle.main.url(forResource: "phrases", withExtension: "json") else {
            print("phrases.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            phrases = try decoder.decode([Phrase].self, from: data)
        } catch {
            print("Failed to load phrases: \(error)")
        }
    }
    
    /// 全フレーズを取得
    func getAllPhrases() -> [Phrase] {
        return phrases
    }
    
    /// カテゴリでフィルタリングしてフレーズを取得
    func getPhrases(for category: StageCategory) -> [Phrase] {
        return phrases.filter { $0.category == category.rawValue }
    }
    
    /// ラストスパート用のコアフレーズを取得
    func getCorePhrases() -> [Phrase] {
        return phrases.filter { $0.isCore }
    }
    
    /// 全ステージを取得
    func getAllStages() -> [Stage] {
        return StageCategory.allCases
            .sorted { $0.order < $1.order }
            .map { category in
                Stage(
                    category: category,
                    phrases: getPhrases(for: category)
                )
            }
    }
}
