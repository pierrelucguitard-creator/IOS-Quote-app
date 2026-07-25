import Foundation

struct Quote: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    let text: String
    let author: String
    let source: QuoteSource
    let createdAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        author: String,
        source: QuoteSource = .curated,
        createdAt: Date = .now
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.source = source
        self.createdAt = createdAt
    }
}

enum QuoteSource: String, Codable, Hashable {
    case curated
    case gemini
}

struct CuratedQuoteDTO: Codable {
    let text: String
    let author: String
}
