# Calendar Widget for iPhone

An iOS calendar widget with an Outlook-inspired design that shows your upcoming events at a glance.

## Features

### Week Widget (Medium & Large)
- Shows 7 days in a horizontal row
- Event text is displayed across multiple lines (not truncated with "...")
- Today is highlighted with a blue circle and subtle background
- Navigate forward/backward through weeks using the chevron buttons
- Available in medium and large widget sizes

### Month Widget (Large)
- Full month calendar grid view
- Event indicator dots showing calendar colors
- First event title preview per day
- Navigate forward/backward through months using the chevron buttons
- Weekend days are subtly dimmed

### Design
- Outlook-inspired clean and professional styling
- Outlook blue (#0078D4) accent color
- Support for both light and dark mode
- Event colors match your iOS calendar colors

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for generating the Xcode project)

## Setup

### 1. Install XcodeGen

```bash
brew install xcodegen
```

### 2. Generate the Xcode project

```bash
cd calender
xcodegen generate
```

This reads `project.yml` and creates `CalenderWidget.xcodeproj`.

### 3. Configure signing

1. Open `CalenderWidget.xcodeproj` in Xcode
2. Select the **CalenderApp** target > Signing & Capabilities
3. Set your Team and Bundle Identifier
4. Do the same for the **CalenderWidgetExtension** target
5. Ensure the widget extension bundle ID is a child of the app's (e.g., `com.yourname.calenderwidget.widget`)

### 4. Configure App Group

1. In both targets, go to Signing & Capabilities
2. Add the **App Groups** capability if not already present
3. Ensure both targets use the same App Group: `group.com.calenderwidget.shared`
4. If you change this identifier, update `WidgetStorage.suiteName` in `Shared/Models.swift`

### 5. Build and run

1. Select your iPhone device or simulator
2. Build and run the **CalenderApp** scheme
3. Grant calendar access when prompted
4. Add the widget to your home screen (long-press > + > search "Calendar Widget")

## Project Structure

```
calender/
├── project.yml                              # XcodeGen project spec
├── CalenderApp/                             # Main companion app
│   ├── CalenderApp.swift                    # App entry point
│   ├── ContentView.swift                    # Main view with setup instructions
│   ├── Info.plist                            # Calendar permission descriptions
│   ├── CalenderApp.entitlements             # App Group entitlement
│   └── Assets.xcassets/                     # App icons and colors
├── Shared/                                  # Shared between app and widget
│   ├── Models.swift                         # CalendarEvent, DayData, WidgetStorage
│   ├── CalendarManager.swift                # EventKit integration
│   ├── Theme.swift                          # Outlook-inspired colors and styling
│   └── DateHelpers.swift                    # Date extension utilities
└── CalenderWidgetExtension/                 # Widget extension
    ├── CalenderWidgetBundle.swift            # Widget bundle (registers both widgets)
    ├── WeekWidget.swift                     # Week widget provider and definition
    ├── WeekWidgetViews.swift                # Week widget SwiftUI views
    ├── MonthWidget.swift                    # Month widget provider and definition
    ├── MonthWidgetViews.swift               # Month widget SwiftUI views
    ├── NavigationIntent.swift               # AppIntents for week/month navigation
    ├── Info.plist                            # Extension configuration
    ├── CalenderWidgetExtension.entitlements  # App Group entitlement
    └── Assets.xcassets/                     # Widget colors
```

## How Navigation Works

Since iOS widgets do not support `ScrollView`, navigation through time is implemented using **AppIntents** with interactive buttons (available on iOS 17+):

- **Week Widget**: Tap the `<` or `>` chevrons in the header to move one week backward or forward
- **Month Widget**: Tap the `<` or `>` chevrons to move one month backward or forward

The current offset is stored in shared `UserDefaults` via App Groups, and the widget timeline is reloaded when the user navigates.

## Notes on Widget Limitations

- **No scroll support**: iOS WidgetKit does not support `ScrollView` or `List`. Navigation buttons are used instead.
- **Static snapshots**: Widgets are rendered as snapshots and refreshed periodically (or on navigation).
- **Event line limits**: The week widget shows 2-3 lines per event in compact mode and up to 3 lines in large mode, balancing readability and aesthetics.
