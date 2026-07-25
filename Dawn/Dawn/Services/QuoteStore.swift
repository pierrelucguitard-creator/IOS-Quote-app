import Foundation
import Combine

@MainActor
final class QuoteStore: ObservableObject {
    @Published private(set) var todayQuote: Quote
    @Published private(set) var favorites: [Quote] = []
    @Published private(set) var isGenerating = false
    @Published var errorMessage: String?
    @Published var toastMessage: String?

    private let gemini = GeminiService()
    private let favoritesKey = "favoriteQuotes"
    private let todayOverrideKey = "todayOverrideQuote"
    private let todayOverrideDateKey = "todayOverrideDate"
    private let curated: [Quote]

    init() {
        curated = Self.loadCuratedQuotes()
        todayQuote = Self.quoteForToday(from: curated)
        favorites = Self.loadFavorites()
        restoreTodayOverrideIfNeeded()
    }

    var isFavorite: Bool {
        favorites.contains { $0.text == todayQuote.text && $0.author == todayQuote.author }
    }

    func refreshToday() {
        if hasValidOverride {
            return
        }
        todayQuote = Self.quoteForToday(from: curated)
    }

    func toggleFavorite() {
        if let index = favorites.firstIndex(where: { $0.text == todayQuote.text && $0.author == todayQuote.author }) {
            favorites.remove(at: index)
            persistFavorites()
            showToast("Removed from Favorites")
        } else {
            favorites.insert(todayQuote, at: 0)
            persistFavorites()
            showToast("Saved to Favorites")
        }
    }

    func removeFavorite(_ quote: Quote) {
        favorites.removeAll { $0.id == quote.id || ($0.text == quote.text && $0.author == quote.author) }
        persistFavorites()
    }

    func generateWithGemini(theme: String? = nil) async {
        guard !isGenerating else { return }
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let quote = try await gemini.generateDailyQuote(theme: theme)
            todayQuote = quote
            persistTodayOverride(quote)
            showToast("New quote from Gemini")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearTodayOverride() {
        UserDefaults.standard.removeObject(forKey: todayOverrideKey)
        UserDefaults.standard.removeObject(forKey: todayOverrideDateKey)
        todayQuote = Self.quoteForToday(from: curated)
        showToast("Back to today’s curated quote")
    }

    // MARK: - Persistence

    private var hasValidOverride: Bool {
        let formatter = Self.dayFormatter
        let stored = UserDefaults.standard.string(forKey: todayOverrideDateKey)
        return stored == formatter.string(from: .now)
    }

    private func restoreTodayOverrideIfNeeded() {
        guard hasValidOverride,
              let data = UserDefaults.standard.data(forKey: todayOverrideKey),
              let quote = try? JSONDecoder().decode(Quote.self, from: data) else {
            return
        }
        todayQuote = quote
    }

    private func persistTodayOverride(_ quote: Quote) {
        if let data = try? JSONEncoder().encode(quote) {
            UserDefaults.standard.set(data, forKey: todayOverrideKey)
            UserDefaults.standard.set(Self.dayFormatter.string(from: .now), forKey: todayOverrideDateKey)
        }
    }

    private func persistFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    private static func loadFavorites() -> [Quote] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let quotes = try? JSONDecoder().decode([Quote].self, from: data) else {
            return []
        }
        return quotes
    }

    private static func loadCuratedQuotes() -> [Quote] {
        guard let url = Bundle.main.url(forResource: "Quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dtos = try? JSONDecoder().decode([CuratedQuoteDTO].self, from: data) else {
            return [
                Quote(text: "Light tomorrow with today.", author: "Elizabeth Barrett Browning")
            ]
        }
        return dtos.map { Quote(text: $0.text, author: $0.author, source: .curated) }
    }

    static func quoteForToday(from quotes: [Quote], date: Date = .now) -> Quote {
        guard !quotes.isEmpty else {
            return Quote(text: "Begin again.", author: "Anonymous")
        }
        let dayIndex = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        return quotes[dayIndex % quotes.count]
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}
