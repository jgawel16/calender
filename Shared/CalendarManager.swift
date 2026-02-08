import EventKit
import SwiftUI

// MARK: - Calendar Manager

final class CalendarManager {
    static let shared = CalendarManager()
    private let store = EKEventStore()

    private init() {}

    // MARK: - Permission Handling

    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await store.requestFullAccessToEvents()
            } catch {
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                store.requestAccess(to: .event) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    var hasAccess: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    // MARK: - Fetch Events

    func fetchEvents(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let ekEvents = store.events(matching: predicate)

        return ekEvents
            .sorted { $0.startDate < $1.startDate }
            .map { event in
                CalendarEvent(
                    id: event.eventIdentifier ?? UUID().uuidString,
                    title: event.title ?? "No Title",
                    startDate: event.startDate,
                    endDate: event.endDate,
                    isAllDay: event.isAllDay,
                    calendarColor: Color(cgColor: event.calendar.cgColor),
                    calendarTitle: event.calendar.title
                )
            }
    }

    func fetchEvents(from startDate: Date, to endDate: Date) -> [Date: [CalendarEvent]] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        guard let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) else {
            return [:]
        }

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let ekEvents = store.events(matching: predicate)

        var eventsByDay: [Date: [CalendarEvent]] = [:]

        for ekEvent in ekEvents {
            let event = CalendarEvent(
                id: ekEvent.eventIdentifier ?? UUID().uuidString,
                title: ekEvent.title ?? "No Title",
                startDate: ekEvent.startDate,
                endDate: ekEvent.endDate,
                isAllDay: ekEvent.isAllDay,
                calendarColor: Color(cgColor: ekEvent.calendar.cgColor),
                calendarTitle: ekEvent.calendar.title
            )

            // Add event to each day it spans
            var currentDay = calendar.startOfDay(for: max(ekEvent.startDate, start))
            let eventEnd = min(ekEvent.endDate, end)

            while currentDay < eventEnd {
                eventsByDay[currentDay, default: []].append(event)
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else { break }
                currentDay = nextDay
            }
        }

        // Sort events within each day
        for (day, events) in eventsByDay {
            eventsByDay[day] = events.sorted { a, b in
                if a.isAllDay != b.isAllDay { return a.isAllDay }
                return a.startDate < b.startDate
            }
        }

        return eventsByDay
    }

    func fetchDayData(startingFrom startDate: Date, days: Int) -> [DayData] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        guard let end = calendar.date(byAdding: .day, value: days - 1, to: start) else {
            return []
        }

        let eventsByDay = fetchEvents(from: start, to: end)

        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else {
                return nil
            }
            let dayStart = calendar.startOfDay(for: date)
            return DayData(date: dayStart, events: eventsByDay[dayStart] ?? [])
        }
    }

    // MARK: - Month Helpers

    func fetchMonthData(for date: Date) -> (days: [DayData], firstWeekday: Int, numberOfDays: Int) {
        let calendar = Calendar.current
        guard let monthRange = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return ([], 0, 0)
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        // Adjust for Monday-first weeks (1=Mon, 7=Sun)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7

        let days = fetchDayData(startingFrom: firstOfMonth, days: monthRange.count)

        return (days, adjustedFirstWeekday, monthRange.count)
    }
}
