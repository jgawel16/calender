import SwiftUI

@main
struct CalenderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleWidgetURL(url)
                }
        }
    }

    private func handleWidgetURL(_ url: URL) {
        guard url.scheme == "calendarwidget",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let dateParam = components.queryItems?.first(where: { $0.name == "date" })?.value else {
            return
        }

        // Parse date string (format: yyyy-MM-dd)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateParam) else { return }

        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Open Google Calendar to the specific date
        let googleCalendarURL = URL(string: "https://calendar.google.com/calendar/r/day/\(year)/\(month)/\(day)")!
        UIApplication.shared.open(googleCalendarURL)
    }
}
