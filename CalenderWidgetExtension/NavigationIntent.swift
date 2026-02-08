import AppIntents
import WidgetKit

// MARK: - Navigation Direction

enum NavigationDirection: String, AppEnum {
    case forward
    case backward

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Direction")

    static var caseDisplayRepresentations: [NavigationDirection: DisplayRepresentation] = [
        .forward: "Forward",
        .backward: "Backward"
    ]
}

// MARK: - Week Navigation Intent

struct WeekNavigateIntent: AppIntent {
    static var title: LocalizedStringResource = "Navigate Week"
    static var description = IntentDescription("Navigate to next or previous week")

    @Parameter(title: "Direction")
    var direction: NavigationDirection

    init() {
        self.direction = .forward
    }

    init(direction: NavigationDirection) {
        self.direction = direction
    }

    func perform() async throws -> some IntentResult {
        let currentOffset = WidgetStorage.weekOffset
        let newOffset: Int

        switch direction {
        case .forward:
            newOffset = currentOffset + 1
        case .backward:
            newOffset = currentOffset - 1
        }

        WidgetStorage.weekOffset = newOffset
        WidgetCenter.shared.reloadTimelines(ofKind: "WeekWidget")

        return .result()
    }
}

// MARK: - Month Navigation Intent

struct MonthNavigateIntent: AppIntent {
    static var title: LocalizedStringResource = "Navigate Month"
    static var description = IntentDescription("Navigate to next or previous month")

    @Parameter(title: "Direction")
    var direction: NavigationDirection

    init() {
        self.direction = .forward
    }

    init(direction: NavigationDirection) {
        self.direction = direction
    }

    func perform() async throws -> some IntentResult {
        let currentOffset = WidgetStorage.monthOffset
        let newOffset: Int

        switch direction {
        case .forward:
            newOffset = currentOffset + 1
        case .backward:
            newOffset = currentOffset - 1
        }

        WidgetStorage.monthOffset = newOffset
        WidgetCenter.shared.reloadTimelines(ofKind: "MonthWidget")

        return .result()
    }
}

// MARK: - Reset to Today Intent

struct ResetToTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset to Today"
    static var description = IntentDescription("Reset calendar view to current date")

    func perform() async throws -> some IntentResult {
        WidgetStorage.weekOffset = 0
        WidgetStorage.monthOffset = 0
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}
