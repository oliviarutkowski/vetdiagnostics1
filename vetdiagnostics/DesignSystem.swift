import SwiftUI

enum AppColor {
    static let accent = Color(red: 0.03, green: 0.58, blue: 0.65)
    static let accentSecondary = Color(red: 0.45, green: 0.75, blue: 0.75)
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
    static let separator = Color(.separator)
    static let success = Color(red: 0.26, green: 0.64, blue: 0.39)
    static let warning = Color(red: 0.95, green: 0.75, blue: 0.10)
    static let danger = Color(red: 0.82, green: 0.23, blue: 0.26)

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var subtleGradient: LinearGradient {
        LinearGradient(
            colors: [Color(.systemGray6), Color(.systemGray5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum AppTypography {
    static var largeTitle: Font { .system(.largeTitle, design: .rounded) }
    static var title: Font { .system(.title, design: .rounded) }
    static var title2: Font { .system(.title2, design: .rounded) }
    static var headline: Font { .system(.headline, design: .rounded) }
    static var body: Font { .system(.body, design: .rounded) }
    static var subheadline: Font { .system(.subheadline, design: .rounded) }
    static var footnote: Font { .system(.footnote, design: .rounded) }
}

struct AppCard<Content: View>: View {
    let title: String?
    let subtitle: String?
    let action: (() -> Void)?
    @ViewBuilder let content: Content

    init(title: String? = nil, subtitle: String? = nil, action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
            if let subtitle {
                Text(subtitle)
                    .font(AppTypography.subheadline)
                    .foregroundColor(.secondary)
            }
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(AppColor.separator.opacity(0.4))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

struct PrimaryGradientButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .imageScale(.medium)
                }
                Text(title)
                    .font(AppTypography.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(AppColor.primaryGradient)
            )
            .shadow(color: AppColor.accent.opacity(0.3), radius: 12, x: 0, y: 8)
        }
        .accessibilityLabel(Text(title))
    }
}

struct StatusBadge: View {
    enum Style {
        case success, warning, info

        var colors: (foreground: Color, background: Color) {
            switch self {
            case .success:
                return (AppColor.success, AppColor.success.opacity(0.15))
            case .warning:
                return (AppColor.warning, AppColor.warning.opacity(0.2))
            case .info:
                return (AppColor.accent, AppColor.accent.opacity(0.15))
            }
        }
    }

    let text: String
    var style: Style = .info

    var body: some View {
        Text(text)
            .font(AppTypography.footnote)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(style.colors.background)
            )
            .foregroundColor(style.colors.foreground)
            .accessibilityLabel(Text(text))
    }
}

struct AppSegmentedControl: View {
    @Binding var selection: Int
    let options: [String]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { option in
                Button {
                    selection = option.id
                } label: {
                    Text(option.title)
                        .font(AppTypography.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Group {
                                if selection == option.id {
                                    Capsule().fill(AppColor.accent.opacity(0.15))
                                } else {
                                    Capsule().fill(Color.clear)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                .foregroundColor(selection == option.id ? AppColor.accent : .secondary)
                .accessibilityLabel(Text(option.title))
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

extension AppSegmentedControl {
    struct Option: Identifiable {
        let id: Int
        let title: String
    }

    var items: [Option] {
        options.enumerated().map { Option(id: $0.offset, title: $0.element) }
    }
}

struct AppTextField: View {
    let title: String
    @Binding var text: String
    var prompt: String = ""
    var symbol: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(.secondary)
            HStack {
                if let symbol {
                    Image(systemName: symbol)
                        .foregroundColor(.secondary)
                }
                TextField(prompt, text: $text)
                    .textFieldStyle(.plain)
                    .font(AppTypography.body)
                    .accessibilityLabel(Text(title))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.tertiarySystemFill))
            )
        }
    }
}

struct AppTextEditor: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(.secondary)
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                )
                .accessibilityLabel(Text(title))
        }
    }
}
