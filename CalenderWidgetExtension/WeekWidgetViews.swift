import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Week Widget Main View

struct WeekWidgetView: View {
    let entry: WeekWidgetEntry

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        VStack(spacing: 0) {
            // Header with navigation
            weekHeader
                .padding(.bottom, 6)

            // 7-day horizontal row
            HStack(spacing: 2) {
                ForEach(entry.days) { day in
                    DayColumnView(
                        day: day,
                        isCompact: widgetFamily == .systemMedium
                    )
                }
            }
        }
        .padding(Theme.widgetPadding)
    }

    // MARK: - Header

    private var weekHeader: some View {
        HStack {
            // Previous week button
            Button(intent: WeekNavigateIntent(direction: .backward)) {
                Image(systemName: "chevron.left")
                    .font(.system(size: Theme.navButtonSize, weight: .semibold))
                    .foregroundStyle(Theme.primaryBlue)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)

            Spacer()

            // Week range title
            VStack(spacing: 1) {
                if entry.weekOffset == 0 {
                    Text("This Week")
                        .font(.system(size: Theme.monthTitleSize, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                } else {
                    Text(entry.displayDate.weekRangeString)
                        .font(.system(size: Theme.monthTitleSize, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                }
            }

            Spacer()

            // Next week button
            Button(intent: WeekNavigateIntent(direction: .forward)) {
                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.navButtonSize, weight: .semibold))
                    .foregroundStyle(Theme.primaryBlue)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Single Day Column

struct DayColumnView: View {
    let day: DayData
    let isCompact: Bool

    private var maxEvents: Int {
        isCompact ? 3 : 6
    }

    var body: some View {
        VStack(spacing: 2) {
            // Day header
            dayHeader
                .padding(.bottom, 2)

            // Events list
            eventsList

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.cardPadding)
        .padding(.horizontal, 2)
        .background(
            RoundedRectangle(cornerRadius: Theme.smallCornerRadius)
                .fill(day.isToday ? Theme.todayBackground : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.smallCornerRadius)
                .strokeBorder(
                    day.isToday ? Theme.todayBorder : Color.clear,
                    lineWidth: 1.5
                )
        )
    }

    // MARK: - Day Header

    private var dayHeader: some View {
        VStack(spacing: 1) {
            Text(day.dayName)
                .font(.system(size: Theme.dayNameSize, weight: .medium))
                .foregroundStyle(day.isToday ? Theme.primaryBlue : Theme.secondaryText)

            ZStack {
                if day.isToday {
                    Circle()
                        .fill(Theme.primaryBlue)
                        .frame(width: 22, height: 22)
                }
                Text(day.dayNumber)
                    .font(.system(size: Theme.dayNumberSize, weight: day.isToday ? .bold : .regular))
                    .foregroundStyle(
                        day.isToday ? Theme.invertedText :
                        day.isWeekend ? Theme.weekendText : Theme.primaryText
                    )
            }
        }
    }

    // MARK: - Events List

    private var eventsList: some View {
        VStack(spacing: Theme.itemSpacing) {
            let visibleEvents = Array(day.events.prefix(maxEvents))
            let remaining = day.events.count - visibleEvents.count

            ForEach(visibleEvents) { event in
                EventPillView(event: event, isCompact: isCompact)
            }

            if remaining > 0 {
                Text("+\(remaining)")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

// MARK: - Event Pill

struct EventPillView: View {
    let event: CalendarEvent
    let isCompact: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Color indicator bar
            RoundedRectangle(cornerRadius: 1)
                .fill(event.calendarColor)
                .frame(width: 2.5)

            // Event content - multiline to show as much text as possible
            VStack(alignment: .leading, spacing: 0) {
                if !event.isAllDay && !isCompact {
                    Text(event.timeString)
                        .font(.system(size: Theme.eventTimeSize, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                        .lineLimit(1)
                }

                Text(event.title)
                    .font(.system(size: Theme.eventTitleSize, weight: .regular))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(isCompact ? 2 : 3)  // Multiple lines to show more text
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(.leading, 3)
            .padding(.vertical, 2)
        }
        .padding(.trailing, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .fill(event.calendarColor.opacity(0.1))
        )
    }
}

// MARK: - Preview

#if DEBUG
struct WeekWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WeekWidgetView(entry: WeekWidgetEntry(
            date: Date(),
            days: (0..<7).map { offset in
                DayData(
                    date: Date().adding(days: offset),
                    events: offset == 0 ? [
                        CalendarEvent(
                            id: "1",
                            title: "Client meeting with design team",
                            startDate: Date(),
                            endDate: Date().addingTimeInterval(3600),
                            isAllDay: false,
                            calendarColor: .blue,
                            calendarTitle: "Work"
                        ),
                        CalendarEvent(
                            id: "2",
                            title: "Birthday party",
                            startDate: Date(),
                            endDate: Date().addingTimeInterval(7200),
                            isAllDay: true,
                            calendarColor: .green,
                            calendarTitle: "Personal"
                        )
                    ] : []
                )
            },
            weekOffset: 0,
            displayDate: Date()
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
