import SwiftUI

@main
struct ThaiFlightSurvivalApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var progressService = ProgressService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsViewModel)
                .environmentObject(progressService)
                .preferredColorScheme(settingsViewModel.colorScheme)
        }
    }
}
