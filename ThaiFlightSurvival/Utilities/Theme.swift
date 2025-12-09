import SwiftUI

/// アプリ全体のカラーテーマ
struct Theme {
    // MARK: - ライトモード
    struct Light {
        static let background = Color(red: 0.92, green: 0.96, blue: 1.0)    // 淡いスカイブルー
        static let cardBackground = Color.white
        static let primaryText = Color(red: 0.2, green: 0.2, blue: 0.25)    // 濃いグレー
        static let secondaryText = Color(red: 0.5, green: 0.5, blue: 0.55)
        static let accent = Color(red: 0.0, green: 0.6, blue: 0.8)          // シアン系
        static let correct = Color(red: 0.2, green: 0.7, blue: 0.4)         // 緑系
        static let incorrect = Color(red: 0.9, green: 0.3, blue: 0.3)       // 赤系
        static let thaiGold = Color(red: 0.85, green: 0.65, blue: 0.13)     // タイの金色
    }
    
    // MARK: - ダークモード
    struct Dark {
        static let background = Color(red: 0.1, green: 0.1, blue: 0.12)     // ダークグレー
        static let cardBackground = Color(red: 0.18, green: 0.18, blue: 0.2) // 淡いグレーカード
        static let primaryText = Color.white
        static let secondaryText = Color(red: 0.7, green: 0.7, blue: 0.75)
        static let accent = Color(red: 0.4, green: 0.8, blue: 0.9)          // 控えめなシアン
        static let correct = Color(red: 0.3, green: 0.8, blue: 0.5)
        static let incorrect = Color(red: 1.0, green: 0.4, blue: 0.4)
        static let thaiGold = Color(red: 0.95, green: 0.75, blue: 0.25)
    }
}

// MARK: - カラースキーム対応のカラー拡張

extension Color {
    static func themeBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.Dark.background : Theme.Light.background
    }
    
    static func themeCardBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.Dark.cardBackground : Theme.Light.cardBackground
    }
    
    static func themePrimaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.Dark.primaryText : Theme.Light.primaryText
    }
    
    static func themeSecondaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.Dark.secondaryText : Theme.Light.secondaryText
    }
    
    static func themeAccent(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.Dark.accent : Theme.Light.accent
    }
    
    static func themeCorrect(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.Dark.correct : Theme.Light.correct
    }
    
    static func themeIncorrect(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.Dark.incorrect : Theme.Light.incorrect
    }
    
    static func themeGold(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.Dark.thaiGold : Theme.Light.thaiGold
    }
}

// MARK: - 共通スタイル

extension View {
    func cardStyle(_ colorScheme: ColorScheme) -> some View {
        self
            .padding()
            .background(Color.themeCardBackground(colorScheme))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
    }
    
    func primaryButtonStyle(_ colorScheme: ColorScheme) -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.themeAccent(colorScheme))
            .cornerRadius(12)
    }
    
    func optionButtonStyle(_ colorScheme: ColorScheme, isSelected: Bool = false, isCorrect: Bool? = nil) -> some View {
        self
            .font(.body)
            .foregroundColor(optionTextColor(colorScheme, isSelected: isSelected, isCorrect: isCorrect))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 60)
            .padding(.horizontal, 16)
            .background(optionBackgroundColor(colorScheme, isSelected: isSelected, isCorrect: isCorrect))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(optionBorderColor(colorScheme, isSelected: isSelected, isCorrect: isCorrect), lineWidth: 2)
            )
    }
    
    private func optionTextColor(_ colorScheme: ColorScheme, isSelected: Bool, isCorrect: Bool?) -> Color {
        if let isCorrect = isCorrect {
            return .white
        }
        return Color.themePrimaryText(colorScheme)
    }
    
    private func optionBackgroundColor(_ colorScheme: ColorScheme, isSelected: Bool, isCorrect: Bool?) -> Color {
        if let isCorrect = isCorrect {
            if isCorrect {
                return Color.themeCorrect(colorScheme)
            } else if isSelected {
                return Color.themeIncorrect(colorScheme)
            }
        }
        return Color.themeCardBackground(colorScheme)
    }
    
    private func optionBorderColor(_ colorScheme: ColorScheme, isSelected: Bool, isCorrect: Bool?) -> Color {
        if let isCorrect = isCorrect {
            if isCorrect {
                return Color.themeCorrect(colorScheme)
            } else if isSelected {
                return Color.themeIncorrect(colorScheme)
            }
        }
        return Color.themeAccent(colorScheme).opacity(0.3)
    }
}
