import SwiftUI

// MARK: - Outlook-Inspired Theme

enum Theme {
    // Primary colors (Outlook-inspired blue)
    static let primaryBlue = Color(red: 0.0, green: 0.47, blue: 0.84)    // #0078D4
    static let primaryDarkBlue = Color(red: 0.0, green: 0.34, blue: 0.64) // #0057A3
    static let lightBlue = Color(red: 0.88, green: 0.94, blue: 1.0)       // #E1F0FF

    // Background colors
    static let widgetBackground = Color(.systemBackground)
    static let cardBackground = Color(red: 0.98, green: 0.98, blue: 0.99)
    static let todayBackground = Color(red: 0.0, green: 0.47, blue: 0.84, opacity: 0.08)

    // Text colors
    static let primaryText = Color(red: 0.13, green: 0.13, blue: 0.13)    // #212121
    static let secondaryText = Color(red: 0.42, green: 0.42, blue: 0.42)  // #6B6B6B
    static let tertiaryText = Color(red: 0.6, green: 0.6, blue: 0.6)
    static let invertedText = Color.white

    // Accent colors for events
    static let weekendText = Color(red: 0.6, green: 0.6, blue: 0.6)

    // Borders and dividers
    static let divider = Color(red: 0.91, green: 0.91, blue: 0.91)        // #E8E8E8
    static let todayBorder = Color(red: 0.0, green: 0.47, blue: 0.84)

    // Navigation
    static let navButtonBackground = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let navButtonForeground = Color(red: 0.42, green: 0.42, blue: 0.42)

    // Spacing
    static let widgetPadding: CGFloat = 12
    static let cardPadding: CGFloat = 6
    static let itemSpacing: CGFloat = 3
    static let cornerRadius: CGFloat = 10
    static let smallCornerRadius: CGFloat = 6

    // Font sizes
    static let dayNumberSize: CGFloat = 16
    static let dayNameSize: CGFloat = 10
    static let eventTitleSize: CGFloat = 11
    static let eventTimeSize: CGFloat = 9
    static let monthTitleSize: CGFloat = 14
    static let navButtonSize: CGFloat = 12
}

// MARK: - View Modifiers

struct TodayHighlight: ViewModifier {
    let isToday: Bool

    func body(content: Content) -> some View {
        content
            .background(
                isToday ? Theme.todayBackground : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.smallCornerRadius)
                    .strokeBorder(isToday ? Theme.todayBorder : Color.clear, lineWidth: 1.5)
            )
    }
}

extension View {
    func todayHighlight(_ isToday: Bool) -> some View {
        modifier(TodayHighlight(isToday: isToday))
    }
}
