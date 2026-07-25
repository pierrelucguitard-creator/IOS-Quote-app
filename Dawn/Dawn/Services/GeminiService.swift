import Foundation

enum GeminiError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiMessage(String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add a Gemini API key in Settings to generate new quotes."
        case .invalidResponse:
            return "Gemini returned an unexpected response."
        case .apiMessage(let message):
            return message
        case .decodingFailed:
            return "Couldn’t read the quote from Gemini."
        }
    }
}

actor GeminiService {
    private let session: URLSession
    private let model = "gemini-2.5-flash"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func generateDailyQuote(theme: String? = nil) async throws -> Quote {
        guard let apiKey = KeychainStore.loadGeminiAPIKey(), !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }

        let themeLine = theme.map { "Theme: \($0)." } ?? "Theme: quiet wisdom for everyday life."
        let prompt = """
        Write one original inspirational quote suitable for a daily quote app.
        \(themeLine)
        Requirements:
        - 1 or 2 sentences maximum
        - Warm, thoughtful, timeless tone
        - No hashtags, no emojis, no quotation marks around the quote
        - Attribute it to a fictional but believable author name, or "Anonymous"
        Return ONLY valid JSON with keys "text" and "author". No markdown.
        """

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.9,
                "maxOutputTokens": 256,
                "responseMimeType": "application/json"
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        if !(200...299).contains(http.statusCode) {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GeminiError.apiMessage(message)
            }
            throw GeminiError.apiMessage("Gemini request failed (\(http.statusCode)).")
        }

        let envelope = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let raw = envelope.candidates?.first?.content.parts.first?.text else {
            throw GeminiError.invalidResponse
        }

        let cleaned = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let quoteData = cleaned.data(using: .utf8) else {
            throw GeminiError.decodingFailed
        }

        let dto = try JSONDecoder().decode(CuratedQuoteDTO.self, from: quoteData)
        let text = dto.text.trimmingCharacters(in: CharacterSet(charactersIn: "\"“”"))
        let author = dto.author.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { throw GeminiError.decodingFailed }

        return Quote(
            text: text,
            author: author.isEmpty ? "Anonymous" : author,
            source: .gemini
        )
    }
}

private struct GeminiResponse: Decodable {
    struct Candidate: Decodable {
        struct Content: Decodable {
            struct Part: Decodable { let text: String? }
            let parts: [Part]
        }
        let content: Content
    }

    let candidates: [Candidate]?
}
