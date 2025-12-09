import Foundation
import AVFoundation

/// タイ語音声読み上げサービス
class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    @Published var isAvailable = true
    
    private init() {
        checkAvailability()
    }
    
    private func checkAvailability() {
        // タイ語音声が利用可能かチェック
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let thaiVoices = voices.filter { $0.language.hasPrefix("th") }
        isAvailable = !thaiVoices.isEmpty
    }
    
    /// タイ語テキストを読み上げる
    func speak(_ text: String) {
        guard isAvailable else { return }
        
        // 既存の読み上げを停止
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "th-TH")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8 // 少しゆっくり
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        isSpeaking = true
        synthesizer.speak(utterance)
        
        // 読み上げ完了後にフラグをリセット（簡易実装）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isSpeaking = false
        }
    }
    
    /// 読み上げを停止
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        }
    }
    
    // MARK: - 効果音
    
    private var correctSoundPlayer: AVAudioPlayer?
    private var incorrectSoundPlayer: AVAudioPlayer?
    
    /// 正解の効果音を再生
    func playCorrectSound() {
        // システムサウンドを使用（タイ風の明るい音）
        AudioServicesPlaySystemSound(1057) // 短い通知音
    }
    
    /// 不正解の効果音を再生
    func playIncorrectSound() {
        // 控えめなエラー音
        AudioServicesPlaySystemSound(1053)
    }
}
