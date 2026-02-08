import SwiftUI
import EventKit

struct ContentView: View {
    @State private var calendarAccessGranted = false
    @State private var showingPermissionAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // App icon / header
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 60))
                        .foregroundStyle(Theme.primaryBlue)

                    Text("Calendar Widget")
                        .font(.title.bold())
                        .foregroundStyle(Theme.primaryText)

                    Text("Your week and month at a glance")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                }
                .padding(.top, 40)

                Spacer()

                // Status card
                VStack(spacing: 16) {
                    // Calendar access status
                    HStack {
                        Image(systemName: calendarAccessGranted ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundStyle(calendarAccessGranted ? .green : .orange)
                            .font(.title3)

                        VStack(alignment: .leading) {
                            Text("Calendar Access")
                                .font(.headline)
                            Text(calendarAccessGranted
                                ? "Access granted. Your events will appear in the widget."
                                : "Calendar access is required to show your events.")
                                .font(.caption)
                                .foregroundStyle(Theme.secondaryText)
                        }

                        Spacer()

                        if !calendarAccessGranted {
                            Button("Grant") {
                                requestCalendarAccess()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.primaryBlue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )

                    // Widget instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Label("How to add the widget", systemImage: "plus.square.on.square")
                            .font(.headline)

                        instructionRow(number: 1, text: "Long-press on your Home Screen")
                        instructionRow(number: 2, text: "Tap the + button in the top-left corner")
                        instructionRow(number: 3, text: "Search for \"Calendar Widget\"")
                        instructionRow(number: 4, text: "Choose Week (medium/large) or Month (large)")
                        instructionRow(number: 5, text: "Tap \"Add Widget\" and place it")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )

                    // Widget features info
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Features", systemImage: "sparkles")
                            .font(.headline)

                        featureRow(icon: "calendar.day.timeline.leading", text: "7-day week view with full event titles")
                        featureRow(icon: "calendar", text: "Full month overview with event dots")
                        featureRow(icon: "chevron.left.chevron.right", text: "Navigate forward and backward in time")
                        featureRow(icon: "paintbrush", text: "Clean Outlook-inspired design")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            checkCalendarAccess()
        }
        .alert("Calendar Access Needed", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable Calendar access in Settings to see your events in the widget.")
        }
    }

    // MARK: - Helpers

    private func instructionRow(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(Theme.invertedText)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Theme.primaryBlue))

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryBlue)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
        }
    }

    private func checkCalendarAccess() {
        let status = EKEventStore.authorizationStatus(for: .event)
        calendarAccessGranted = (status == .fullAccess)
    }

    private func requestCalendarAccess() {
        Task {
            let granted = await CalendarManager.shared.requestAccess()
            await MainActor.run {
                calendarAccessGranted = granted
                if !granted {
                    showingPermissionAlert = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
