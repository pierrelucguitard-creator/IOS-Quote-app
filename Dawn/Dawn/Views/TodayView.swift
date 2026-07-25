import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: QuoteStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var atmosphere = Atmosphere.current()
    @State private var revealed = false
    @State private var showShare = false
    @State private var showGenerateOptions = false

    private let dateText: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: .now)
    }()

    var body: some View {
        ZStack {
            AmbientBackground(atmosphere: atmosphere)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer(minLength: 20)

                QuoteCard(
                    quote: store.todayQuote,
                    atmosphere: atmosphere,
                    revealed: revealed
                )
                .padding(.horizontal, 24)
                .id(store.todayQuote.id)

                Spacer(minLength: 20)

                actionBar
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)
            }

            if let toast = store.toastMessage {
                VStack {
                    ToastBanner(message: toast)
                        .padding(.top, 8)
                    Spacer()
                }
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: store.toastMessage)
                .zIndex(2)
            }
        }
        .onAppear {
            atmosphere = Atmosphere.current()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.84).delay(0.15)) {
                revealed = true
            }
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { store.errorMessage = nil }
        } message: {
            Text(store.errorMessage ?? "")
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [shareText])
                .presentationDetents([.medium, .large])
        }
        .confirmationDialog("Generate with Gemini", isPresented: $showGenerateOptions, titleVisibility: .visible) {
            Button("Fresh daily quote") {
                Task { await store.generateWithGemini() }
            }
            Button("Quiet & reflective") {
                Task { await store.generateWithGemini(theme: "quiet reflection and presence") }
            }
            Button("Courage & resolve") {
                Task { await store.generateWithGemini(theme: "courage and gentle resolve") }
            }
            Button("Creativity & craft") {
                Task { await store.generateWithGemini(theme: "creativity, craft, and making things") }
            }
            if store.todayQuote.source == .gemini {
                Button("Restore curated quote", role: .destructive) {
                    withAnimation { store.clearTodayOverride() }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Gemini writes an original quote for this moment.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("DAWN")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(3.2)
                .foregroundStyle(.secondary)

            Text(atmosphere.greeting)
                .font(.system(.title2, design: .serif, weight: .regular))
                .foregroundStyle(.primary)

            Text(dateText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionBar: some View {
        HStack(spacing: 18) {
            GlassToolbarButton(
                systemName: store.isFavorite ? "heart.fill" : "heart",
                isActive: false
            ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    store.toggleFavorite()
                }
            }

            GlassToolbarButton(systemName: "square.and.arrow.up") {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showShare = true
            }

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showGenerateOptions = true
            } label: {
                HStack(spacing: 8) {
                    if store.isGenerating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(store.isGenerating ? "Writing…" : "Gemini")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(height: 56)
                .background {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.18, green: 0.18, blue: 0.20),
                                    Color(red: 0.06, green: 0.06, blue: 0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.28), radius: 16, y: 8)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(store.isGenerating)
        }
    }

    private var shareText: String {
        "“\(store.todayQuote.text)”\n— \(store.todayQuote.author)\n\nShared from Dawn"
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
