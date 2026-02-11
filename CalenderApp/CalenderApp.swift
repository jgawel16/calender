import SwiftUI

@main
struct CalenderApp: App {
    @State private var openedFromWidget = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if openedFromWidget {
                    // Show transparent view during redirect - no UI flash
                    Color.clear
                } else {
                    ContentView()
                }
            }
            .onOpenURL { url in
                openedFromWidget = true
                handleWidgetURL(url)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active && openedFromWidget {
                    // User returned from Google Calendar - suspend the app
                    // so they go back to the home screen, not this app
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        suspendApp()
                        openedFromWidget = false
                    }
                }
            }
        }
    }

    private func handleWidgetURL(_ url: URL) {
        guard url.scheme == "calendarwidget",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let dateParam = components.queryItems?.first(where: { $0.name == "date" })?.value else {
            openedFromWidget = false
            return
        }

        // Parse date string (format: yyyy-MM-dd)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateParam) else {
            openedFromWidget = false
            return
        }

        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Open Google Calendar to the specific date
        let googleCalendarURL = URL(string: "https://calendar.google.com/calendar/r/day/\(year)/\(month)/\(day)")!
        UIApplication.shared.open(googleCalendarURL)
    }

    private func suspendApp() {
        // Send app to background so user returns to home screen
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
}
