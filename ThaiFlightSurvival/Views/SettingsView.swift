import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var progressService: ProgressService
    
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground(colorScheme)
                    .ignoresSafeArea()
                
                List {
                    // 外観
                    Section {
                        Picker("外観モード", selection: $settingsViewModel.appearanceMode) {
                            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                    } header: {
                        Text("外観")
                    }
                    
                    // 音声
                    Section {
                        Toggle("音声自動再生", isOn: $settingsViewModel.autoPlayAudio)
                        Toggle("効果音", isOn: $settingsViewModel.soundEffectsEnabled)
                        Toggle("バイブレーション", isOn: $settingsViewModel.hapticEnabled)
                    } header: {
                        Text("音声・フィードバック")
                    } footer: {
                        Text("音声自動再生をONにすると、問題表示時と回答後にタイ語が自動で読み上げられます。")
                    }
                    
                    // 進捗リセット
                    Section {
                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("進捗をリセット")
                            }
                            .foregroundColor(.red)
                        }
                    } header: {
                        Text("データ")
                    } footer: {
                        Text("すべてのステージのクリア状況と連続正解数がリセットされます。")
                    }
                    
                    // アプリ情報
                    Section {
                        HStack {
                            Text("バージョン")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(Color.themeSecondaryText(colorScheme))
                        }
                    } header: {
                        Text("アプリ情報")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
            .alert("進捗をリセット", isPresented: $showResetConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("リセット", role: .destructive) {
                    progressService.resetAllProgress()
                }
            } message: {
                Text("すべてのステージのクリア状況と連続正解数がリセットされます。この操作は取り消せません。")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(ProgressService())
}
