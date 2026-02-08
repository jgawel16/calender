import WidgetKit
import SwiftUI

@main
struct CalenderWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeekWidget()
        MonthWidget()
    }
}
