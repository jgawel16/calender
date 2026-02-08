import Foundation

extension Date {
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    var shortMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }

    var weekRangeString: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"

        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: self) else {
            return formatter.string(from: self)
        }

        let startMonth = calendar.component(.month, from: self)
        let endMonth = calendar.component(.month, from: endOfWeek)

        if startMonth == endMonth {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "d"
            return "\(dayFormatter.string(from: self)) - \(formatter.string(from: endOfWeek))"
        } else {
            return "\(formatter.string(from: self)) - \(formatter.string(from: endOfWeek))"
        }
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
}
