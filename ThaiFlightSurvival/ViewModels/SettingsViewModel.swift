import Foundation
import SwiftUI

/// アプリの外観モード
enum AppearanceMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "システムに従う"
        case .light: return "ライト"
        case .dark: return "ダーク"
        }
    }
}

/// 設定画面のViewModel
class SettingsViewModel: ObservableObject {
    @Published var appearanceMode: AppearanceMode = .system {
        didSet { saveSettings() }
    }
    @Published var autoPlayAudio: Bool = true {
        didSet { saveSettings() }
    }
    @Published var soundEffectsEnabled: Bool = true {
        didSet { saveSettings() }
    }
    @Published var hapticEnabled: Bool = true {
        didSet { saveSettings() }
    }
    
    private let appearanceKey = "appearanceMode"
    private let autoPlayKey = "autoPlayAudio"
    private let soundEffectsKey = "soundEffectsEnabled"
    private let hapticKey = "hapticEnabled"
    
    var colorScheme: ColorScheme? {
        switch appearanceMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    init() {
        loadSettings()
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
        UserDefaults.standard.set(autoPlayAudio, forKey: autoPlayKey)
        UserDefaults.standard.set(soundEffectsEnabled, forKey: soundEffectsKey)
        UserDefaults.standard.set(hapticEnabled, forKey: hapticKey)
    }
    
    private func loadSettings() {
        if let modeString = UserDefaults.standard.string(forKey: appearanceKey),
           let mode = AppearanceMode(rawValue: modeString) {
            appearanceMode = mode
        }
        
        // デフォルトはtrue
        if UserDefaults.standard.object(forKey: autoPlayKey) != nil {
            autoPlayAudio = UserDefaults.standard.bool(forKey: autoPlayKey)
        }
        if UserDefaults.standard.object(forKey: soundEffectsKey) != nil {
            soundEffectsEnabled = UserDefaults.standard.bool(forKey: soundEffectsKey)
        }
        if UserDefaults.standard.object(forKey: hapticKey) != nil {
            hapticEnabled = UserDefaults.standard.bool(forKey: hapticKey)
        }
    }
}
