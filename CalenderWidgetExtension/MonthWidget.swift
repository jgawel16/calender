import WidgetKit
import SwiftUI

// MARK: - Month Widget Timeline Entry

struct MonthWidgetEntry: TimelineEntry {
    let date: Date
    let displayMonth: Date
    let days: [DayData]
    let firstWeekdayOffset: Int
    let numberOfDays: Int
    let monthOffset: Int
}

// MARK: - Month Widget Timeline Provider

struct MonthWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonthWidgetEntry {
        createEntry(offset: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (MonthWidgetEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MonthWidgetEntry>) -> Void) {
        let entry = createEntry()

        // Refresh at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: Date().adding(days: 1))
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func createEntry(offset: Int? = nil) -> MonthWidgetEntry {
        let monthOffset = offset ?? WidgetStorage.monthOffset
        let displayMonth = Date().startOfMonth.adding(months: monthOffset)

        let (days, firstWeekday, numberOfDays) = CalendarManager.shared.fetchMonthData(for: displayMonth)

        return MonthWidgetEntry(
            date: Date(),
            displayMonth: displayMonth,
            days: days,
            firstWeekdayOffset: firstWeekday,
            numberOfDays: numberOfDays,
            monthOffset: monthOffset
        )
    }
}

// MARK: - Month Widget Definition

struct MonthWidget: Widget {
    let kind: String = "MonthWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MonthWidgetProvider()) { entry in
            MonthWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Month Calendar")
        .description("Shows a full month overview with event indicators.")
        .supportedFamilies([.systemLarge])
    }
}
