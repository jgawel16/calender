import SwiftUI
import WidgetKit

// MARK: - Date URL Helper

private func monthDateURL(for date: Date) -> URL {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateString = formatter.string(from: date)
    return URL(string: "calendarwidget://day?date=\(dateString)")!
}

// MARK: - Month Widget Main View

struct MonthWidgetView: View {
    let entry: MonthWidgetEntry

    private let weekdayHeaders = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 6) {
            // Header
            monthHeader

            // Weekday headers
            weekdayHeaderRow

            // Calendar grid
            calendarGrid
        }
        .padding(Theme.widgetPadding)
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Spacer()
            Text(entry.displayMonth.monthYearString)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.primaryText)
            Spacer()
        }
    }

    // MARK: - Weekday Header Row

    private var weekdayHeaderRow: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(weekdayHeaders, id: \.self) { day in
                Text(day)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(
                        (day == "SA" || day == "SU") ? Theme.weekendText : Theme.secondaryText
                    )
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let totalSlots = entry.firstWeekdayOffset + entry.numberOfDays

        return LazyVGrid(columns: columns, spacing: 3) {
            // Empty cells before the first day
            ForEach(0..<entry.firstWeekdayOffset, id: \.self) { _ in
                Color.clear
                    .frame(height: monthCellHeight)
            }

            // Day cells - each tappable to open Google Calendar
            ForEach(entry.days) { day in
                Link(destination: monthDateURL(for: day.date)) {
                    MonthDayCellView(day: day)
                        .frame(height: monthCellHeight)
                }
            }

            // Padding cells at the end to complete the grid
            let remainingSlots = (7 - (totalSlots % 7)) % 7
            ForEach(0..<remainingSlots, id: \.self) { _ in
                Color.clear
                    .frame(height: monthCellHeight)
            }
        }
    }

    private var monthCellHeight: CGFloat {
        38
    }
}

// MARK: - Month Day Cell

struct MonthDayCellView: View {
    let day: DayData

    var body: some View {
        VStack(spacing: 1) {
            // Day number
            ZStack {
                if day.isToday {
                    Circle()
                        .fill(Theme.primaryBlue)
                        .frame(width: 20, height: 20)
                }
                Text(day.dayNumber)
                    .font(.system(size: 12, weight: day.isToday ? .bold : .regular))
                    .foregroundStyle(
                        day.isToday ? Theme.invertedText :
                        day.isWeekend ? Theme.weekendText : Theme.primaryText
                    )
            }

            // Event indicators (dots)
            if !day.events.isEmpty {
                HStack(spacing: 2) {
                    let visibleEvents = Array(day.events.prefix(3))
                    ForEach(visibleEvents) { event in
                        Circle()
                            .fill(event.calendarColor)
                            .frame(width: 4, height: 4)
                    }
                }
            }

            // First event title (if any)
            if let firstEvent = day.events.first {
                Text(firstEvent.title)
                    .font(.system(size: 7, weight: .regular))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 1)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(day.isToday ? Theme.todayBackground : Color.clear)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct MonthWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MonthWidgetView(entry: MonthWidgetEntry(
            date: Date(),
            displayMonth: Date(),
            days: (1...28).map { dayNum in
                DayData(
                    date: Calendar.current.date(
                        from: DateComponents(year: 2026, month: 2, day: dayNum)
                    ) ?? Date(),
                    events: dayNum % 3 == 0 ? [
                        CalendarEvent(
                            id: "\(dayNum)",
                            title: "Meeting",
                            startDate: Date(),
                            endDate: Date(),
                            isAllDay: false,
                            calendarColor: .blue,
                            calendarTitle: "Work"
                        )
                    ] : []
                )
            },
            firstWeekdayOffset: 6,
            numberOfDays: 28,
            monthOffset: 0
        ))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
