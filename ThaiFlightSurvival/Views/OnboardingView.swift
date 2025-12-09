import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var progressService: ProgressService
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            icon: "airplane",
            title: "機内で完結！",
            description: "オフラインで使えるから、機内モードでも安心。\n着陸までの3時間で、到着直後に必要なタイ語だけを覚えよう。"
        ),
        OnboardingPage(
            icon: "bubble.left.and.bubble.right.fill",
            title: "話せる・聞けるを",
            description: "「聞いて理解」と「話して伝える」の2モードで、\n反射的にフレーズが出てくるようになる。"
        ),
        OnboardingPage(
            icon: "flag.checkered",
            title: "5問連続で突破！",
            description: "各シーン5問連続正解でクリア。\n間違えたらやり直し。シンプルだけど効果的。"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.themeBackground(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ページインジケーター
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.themeAccent(colorScheme) : Color.themeSecondaryText(colorScheme).opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 60)
                
                // コンテンツ
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // ボタン
                VStack(spacing: 16) {
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            progressService.completeOnboarding()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "次へ" : "今すぐ始める")
                            .primaryButtonStyle(colorScheme)
                    }
                    
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            progressService.completeOnboarding()
                        }) {
                            Text("スキップ")
                                .font(.subheadline)
                                .foregroundColor(Color.themeSecondaryText(colorScheme))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(Color.themeAccent(colorScheme))
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.themePrimaryText(colorScheme))
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.themeSecondaryText(colorScheme))
                .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(SettingsViewModel())
        .environmentObject(ProgressService())
}
