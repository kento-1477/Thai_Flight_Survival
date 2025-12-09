import Foundation

/// タイ語フレーズのデータモデル
struct Phrase: Codable, Identifiable, Equatable {
    let id: Int
    let category: String      // airport, transport, hotel, food, basic
    let thai: String          // タイ語表記（音声読み上げ用）
    let reading: String       // カタカナ読み（発音ガイド）
    let meaning: String       // 日本語の意味
    let note: String?         // 補足説明（使用シーンなど）
    let isCore: Bool          // ラストスパート対象フラグ
    
    enum CodingKeys: String, CodingKey {
        case id, category, thai, reading, meaning, note
        case isCore = "is_core"
    }
    
    /// 音声読み上げ用のテキストを取得（カタカナや補足を除外）
    var speechText: String {
        thai
    }
}

/// ステージのカテゴリ
enum StageCategory: String, CaseIterable {
    case airport = "airport"
    case transport = "transport"
    case hotel = "hotel"
    case food = "food"
    case basic = "basic"
    
    var displayName: String {
        switch self {
        case .airport: return "空港・機内"
        case .transport: return "移動"
        case .hotel: return "ホテル"
        case .food: return "食事"
        case .basic: return "基本・緊急"
        }
    }
    
    var description: String {
        switch self {
        case .airport: return "入国審査、両替、トイレ"
        case .transport: return "タクシー、行き先指示"
        case .hotel: return "チェックイン、Wi-Fi、朝食"
        case .food: return "注文、辛さ、パクチー抜き"
        case .basic: return "あいさつ、お願い、トラブル時"
        }
    }
    
    var iconName: String {
        switch self {
        case .airport: return "airplane"
        case .transport: return "car.fill"
        case .hotel: return "building.2.fill"
        case .food: return "fork.knife"
        case .basic: return "hand.wave.fill"
        }
    }
    
    var order: Int {
        switch self {
        case .airport: return 0
        case .transport: return 1
        case .hotel: return 2
        case .food: return 3
        case .basic: return 4
        }
    }
}
