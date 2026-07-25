import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var store: QuoteStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground(atmosphere: Atmosphere.current())
                    .opacity(0.55)

                if store.favorites.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(store.favorites) { quote in
                                FavoriteRow(quote: quote) {
                                    withAnimation {
                                        store.removeFavorite(quote)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart")
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundStyle(.secondary)

            Text("No favorites yet")
                .font(.system(.title3, design: .serif))

            Text("Save quotes you want to return to.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

private struct FavoriteRow: View {
    let quote: Quote
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(quote.text)
                .font(.system(.body, design: .serif))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(quote.author)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                if quote.source == .gemini {
                    Label("Gemini", systemImage: "sparkles")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "heart.slash")
                        .font(.footnote.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                }
        }
    }
}
