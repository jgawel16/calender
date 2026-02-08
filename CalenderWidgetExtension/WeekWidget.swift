import WidgetKit
import SwiftUI

// MARK: - Week Widget Timeline Entry

struct WeekWidgetEntry: TimelineEntry {
    let date: Date
    let days: [DayData]
    let weekOffset: Int
    let displayDate: Date // The start date of the displayed week
}

// MARK: - Week Widget Timeline Provider

struct WeekWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeekWidgetEntry {
        WeekWidgetEntry(
            date: Date(),
            days: generatePlaceholderDays(),
            weekOffset: 0,
            displayDate: Date()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeekWidgetEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeekWidgetEntry>) -> Void) {
        let entry = createEntry()

        // Refresh at midnight or in 30 minutes, whichever is sooner
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: Date().adding(days: 1))
        let thirtyMin = Date().addingTimeInterval(30 * 60)
        let nextRefresh = min(tomorrow, thirtyMin)

        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func createEntry() -> WeekWidgetEntry {
        let offset = WidgetStorage.weekOffset
        let startDate = Date().startOfWeek.adding(weeks: offset)
        let days = CalendarManager.shared.fetchDayData(startingFrom: startDate, days: 7)

        return WeekWidgetEntry(
            date: Date(),
            days: days,
            weekOffset: offset,
            displayDate: startDate
        )
    }

    private func generatePlaceholderDays() -> [DayData] {
        (0..<7).map { offset in
            DayData(date: Date().adding(days: offset), events: [])
        }
    }
}

// MARK: - Week Widget Definition

struct WeekWidget: Widget {
    let kind: String = "WeekWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeekWidgetProvider()) { entry in
            WeekWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Week Calendar")
        .description("Shows your upcoming 7 days with calendar events.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
