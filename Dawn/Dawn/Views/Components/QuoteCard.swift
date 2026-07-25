import SwiftUI

struct QuoteCard: View {
    let quote: Quote
    let atmosphere: Atmosphere
    var revealed: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Image(systemName: "quote.opening")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(atmosphere.accent.opacity(0.85))
                .opacity(revealed ? 1 : 0)
                .offset(y: revealed ? 0 : 8)

            Text(quote.text)
                .font(.system(.largeTitle, design: .serif, weight: .regular))
                .foregroundStyle(.primary.opacity(0.92))
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(revealed ? 1 : 0)
                .offset(y: revealed ? 0 : 16)

            Text(quote.author)
                .font(.system(.body, design: .default, weight: .medium))
                .tracking(0.4)
                .foregroundStyle(.secondary)
                .opacity(revealed ? 1 : 0)
                .offset(y: revealed ? 0 : 12)

            if quote.source == .gemini {
                Label("Crafted with Gemini", systemImage: "sparkles")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(atmosphere.accent)
                    .padding(.top, 4)
                    .opacity(revealed ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(28)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.18 : 0.55),
                                    .white.opacity(colorScheme == .dark ? 0.04 : 0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: .black.opacity(colorScheme == .dark ? 0.35 : 0.08),
                    radius: 28,
                    y: 14
                )
        }
        .animation(.spring(response: 0.7, dampingFraction: 0.82), value: revealed)
        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: quote.id)
    }
}
