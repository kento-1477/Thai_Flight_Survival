import Foundation
import UIKit

/// ハプティックフィードバックサービス
class HapticService {
    static let shared = HapticService()
    
    private init() {}
    
    /// 正解時の軽いハプティック
    func playCorrectFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// 不正解時の少し異なるハプティック
    func playIncorrectFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// ボタンタップ用の軽いハプティック
    func playTapFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// セレクション変更用のハプティック
    func playSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
