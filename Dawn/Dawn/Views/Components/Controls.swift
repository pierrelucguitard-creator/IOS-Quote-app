import SwiftUI

struct GlassToolbarButton: View {
    let systemName: String
    var isActive: Bool = false
    var isProminent: Bool = false
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: isProminent ? 20 : 18, weight: .semibold))
                .foregroundStyle(isActive ? Color.white : .primary.opacity(0.9))
                .frame(width: isProminent ? 56 : 48, height: isProminent ? 56 : 48)
                .background {
                    if isProminent {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.20, green: 0.20, blue: 0.22),
                                        Color(red: 0.08, green: 0.08, blue: 0.10)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Circle()
                                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.12 : 0.35), lineWidth: 1)
                            }
                    }
                }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ToastBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}
