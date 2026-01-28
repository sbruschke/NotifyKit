import AppIntents

struct NotifyKitShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SendNotificationIntent(),
            phrases: [
                "Send notification with \(.applicationName)",
                "Send a \(.applicationName) notification",
                "Notify me with \(.applicationName)",
                "Create notification in \(.applicationName)"
            ],
            shortTitle: "Send Notification",
            systemImageName: "bell.badge"
        )

        AppShortcut(
            intent: ScheduleNotificationIntent(),
            phrases: [
                "Schedule notification with \(.applicationName)",
                "Schedule a \(.applicationName) notification",
                "Set reminder with \(.applicationName)"
            ],
            shortTitle: "Schedule Notification",
            systemImageName: "clock.badge"
        )

        AppShortcut(
            intent: ScheduleDelayedNotificationIntent(),
            phrases: [
                "Send delayed notification with \(.applicationName)",
                "Remind me later with \(.applicationName)"
            ],
            shortTitle: "Delayed Notification",
            systemImageName: "timer"
        )

        AppShortcut(
            intent: CancelNotificationIntent(),
            phrases: [
                "Cancel notification in \(.applicationName)",
                "Remove notification from \(.applicationName)"
            ],
            shortTitle: "Cancel Notification",
            systemImageName: "bell.slash"
        )

        AppShortcut(
            intent: CancelAllNotificationsIntent(),
            phrases: [
                "Cancel all \(.applicationName) notifications",
                "Clear all notifications from \(.applicationName)"
            ],
            shortTitle: "Cancel All",
            systemImageName: "bell.slash.fill"
        )

        AppShortcut(
            intent: SetBadgeIntent(),
            phrases: [
                "Set badge with \(.applicationName)",
                "Update \(.applicationName) badge"
            ],
            shortTitle: "Set Badge",
            systemImageName: "app.badge"
        )

        AppShortcut(
            intent: ClearBadgeIntent(),
            phrases: [
                "Clear badge with \(.applicationName)",
                "Remove \(.applicationName) badge"
            ],
            shortTitle: "Clear Badge",
            systemImageName: "app"
        )

        AppShortcut(
            intent: GetPendingNotificationsCountIntent(),
            phrases: [
                "How many notifications in \(.applicationName)",
                "Count pending \(.applicationName) notifications"
            ],
            shortTitle: "Pending Count",
            systemImageName: "number.circle"
        )
    }
}
