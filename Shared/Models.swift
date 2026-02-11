import Foundation
import SwiftUI

// MARK: - Calendar Event Model

struct CalendarEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let calendarColor: Color
    let calendarTitle: String

    var timeString: String {
        if isAllDay {
            return "All day"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startDate)
    }

    var durationString: String {
        if isAllDay { return "All day" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - Day Data Model

struct DayData: Identifiable {
    let id = UUID()
    let date: Date
    let events: [CalendarEvent]

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date).uppercased()
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }
}

// MARK: - Week Offset Storage

struct WidgetStorage {
    static let weekOffsetKey = "weekWidgetOffset"
    static let monthOffsetKey = "monthWidgetOffset"

    static var weekOffset: Int {
        get { UserDefaults.standard.integer(forKey: weekOffsetKey) }
        set { UserDefaults.standard.set(newValue, forKey: weekOffsetKey) }
    }

    static var monthOffset: Int {
        get { UserDefaults.standard.integer(forKey: monthOffsetKey) }
        set { UserDefaults.standard.set(newValue, forKey: monthOffsetKey) }
    }
}
