import SwiftUI

enum Atmosphere {
    case morning
    case midday
    case evening
    case night

    static func current(for date: Date = .now) -> Atmosphere {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<11: return .morning
        case 11..<17: return .midday
        case 17..<21: return .evening
        default: return .night
        }
    }

    var title: String {
        switch self {
        case .morning: "Morning"
        case .midday: "Afternoon"
        case .evening: "Evening"
        case .night: "Night"
        }
    }

    var greeting: String {
        switch self {
        case .morning: "Good morning"
        case .midday: "Good afternoon"
        case .evening: "Good evening"
        case .night: "Good night"
        }
    }

    func colors(for scheme: ColorScheme) -> [Color] {
        switch (self, scheme) {
        case (.morning, .light):
            return [
                Color(red: 1.00, green: 0.93, blue: 0.86),
                Color(red: 0.98, green: 0.82, blue: 0.70),
                Color(red: 0.86, green: 0.72, blue: 0.78)
            ]
        case (.morning, .dark):
            return [
                Color(red: 0.18, green: 0.12, blue: 0.14),
                Color(red: 0.35, green: 0.20, blue: 0.18),
                Color(red: 0.22, green: 0.16, blue: 0.28)
            ]
        case (.midday, .light):
            return [
                Color(red: 0.90, green: 0.95, blue: 1.00),
                Color(red: 0.78, green: 0.88, blue: 0.96),
                Color(red: 0.92, green: 0.90, blue: 0.86)
            ]
        case (.midday, .dark):
            return [
                Color(red: 0.08, green: 0.12, blue: 0.18),
                Color(red: 0.12, green: 0.20, blue: 0.30),
                Color(red: 0.10, green: 0.14, blue: 0.22)
            ]
        case (.evening, .light):
            return [
                Color(red: 0.98, green: 0.90, blue: 0.88),
                Color(red: 0.86, green: 0.74, blue: 0.82),
                Color(red: 0.70, green: 0.72, blue: 0.88)
            ]
        case (.evening, .dark):
            return [
                Color(red: 0.14, green: 0.10, blue: 0.18),
                Color(red: 0.28, green: 0.14, blue: 0.22),
                Color(red: 0.16, green: 0.14, blue: 0.30)
            ]
        case (.night, .light):
            return [
                Color(red: 0.88, green: 0.90, blue: 0.96),
                Color(red: 0.78, green: 0.80, blue: 0.90),
                Color(red: 0.92, green: 0.90, blue: 0.94)
            ]
        case (.night, .dark):
            return [
                Color(red: 0.05, green: 0.06, blue: 0.10),
                Color(red: 0.10, green: 0.10, blue: 0.18),
                Color(red: 0.08, green: 0.08, blue: 0.14)
            ]
        }
    }

    var accent: Color {
        switch self {
        case .morning: Color(red: 0.86, green: 0.48, blue: 0.32)
        case .midday: Color(red: 0.28, green: 0.52, blue: 0.78)
        case .evening: Color(red: 0.72, green: 0.38, blue: 0.52)
        case .night: Color(red: 0.55, green: 0.58, blue: 0.85)
        }
    }
}

struct AmbientBackground: View {
    let atmosphere: Atmosphere
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let colors = atmosphere.colors(for: colorScheme)

        ZStack {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(colors[1].opacity(colorScheme == .dark ? 0.45 : 0.55))
                .frame(width: 360, height: 360)
                .blur(radius: 80)
                .offset(x: 120, y: -220)

            Circle()
                .fill(colors[2].opacity(colorScheme == .dark ? 0.40 : 0.50))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -140, y: 260)

            // Soft vignette for depth
            RadialGradient(
                colors: [.clear, Color.black.opacity(colorScheme == .dark ? 0.35 : 0.06)],
                center: .center,
                startRadius: 80,
                endRadius: 520
            )
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.2), value: atmosphere.title)
    }
}
