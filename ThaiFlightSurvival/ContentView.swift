import SwiftUI

struct ContentView: View {
    @EnvironmentObject var progressService: ProgressService
    
    var body: some View {
        Group {
            if progressService.hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsViewModel())
        .environmentObject(ProgressService())
}
