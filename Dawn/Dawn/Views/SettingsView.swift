import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var appearanceRaw = Appearance.system.rawValue
    @State private var apiKey = ""
    @State private var isKeySaved = false
    @State private var showKey = false
    @State private var statusMessage: String?

    private var appearance: Binding<Appearance> {
        Binding(
            get: { Appearance(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Appearance", selection: appearance) {
                        ForEach(Appearance.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Look")
                } footer: {
                    Text("Dawn adapts its ambient palette to the time of day.")
                }

                Section {
                    HStack {
                        Group {
                            if showKey {
                                TextField("Gemini API key", text: $apiKey)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("Gemini API key", text: $apiKey)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                        }
                        .font(.body.monospaced())

                        Button {
                            showKey.toggle()
                        } label: {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        saveKey()
                    } label: {
                        Label(isKeySaved ? "Update API Key" : "Save API Key", systemImage: "key.fill")
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    if isKeySaved {
                        Button("Remove API Key", role: .destructive) {
                            KeychainStore.deleteGeminiAPIKey()
                            apiKey = ""
                            isKeySaved = false
                            statusMessage = "API key removed"
                        }
                    }
                } header: {
                    Text("Gemini")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Get a free key from Google AI Studio, then generate original daily quotes in the Today tab.")
                        if let statusMessage {
                            Text(statusMessage)
                                .foregroundStyle(.secondary)
                        }
                        Link("Open Google AI Studio", destination: URL(string: "https://aistudio.google.com/apikey")!)
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "Dawn")
                    LabeledContent("Version", value: "1.0")
                    Text("A quiet daily quote experience — curated wisdom, with optional Gemini-crafted originals.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                if let existing = KeychainStore.loadGeminiAPIKey(), !existing.isEmpty {
                    apiKey = existing
                    isKeySaved = true
                }
            }
        }
    }

    private func saveKey() {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        KeychainStore.saveGeminiAPIKey(trimmed)
        isKeySaved = true
        statusMessage = "API key saved securely in Keychain"
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
