import AppIntents
import UserNotifications

struct CancelNotificationIntent: AppIntent {
    static var title: LocalizedStringResource = "Cancel Notification"
    static var description = IntentDescription("Cancel a scheduled notification by its ID")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Notification ID", description: "The ID returned when scheduling")
    var notificationId: String

    static var parameterSummary: some ParameterSummary {
        Summary("Cancel notification \(\.$notificationId)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = NotificationManager.shared
        manager.cancelNotification(identifier: notificationId)
        return .result()
    }
}

struct CancelAllNotificationsIntent: AppIntent {
    static var title: LocalizedStringResource = "Cancel All Notifications"
    static var description = IntentDescription("Cancel all pending and delivered notifications")

    static var openAppWhenRun: Bool = false

    static var parameterSummary: some ParameterSummary {
        Summary("Cancel all notifications")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        let manager = NotificationManager.shared

        // Get count before canceling
        await manager.refreshNotificationLists()
        let count = manager.pendingNotifications.count + manager.deliveredNotifications.count

        manager.cancelAllNotifications()

        return .result(value: count)
    }
}

struct CancelNotificationsByThreadIntent: AppIntent {
    static var title: LocalizedStringResource = "Cancel Notifications by Thread"
    static var description = IntentDescription("Cancel all notifications with a specific thread ID")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Thread ID", description: "The thread identifier to cancel")
    var threadIdentifier: String

    static var parameterSummary: some ParameterSummary {
        Summary("Cancel notifications in thread \(\.$threadIdentifier)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = NotificationManager.shared
        await manager.cancelNotificationsByThread(threadIdentifier: threadIdentifier)
        return .result()
    }
}

// MARK: - Badge Management Intents

struct SetBadgeIntent: AppIntent {
    static var title: LocalizedStringResource = "Set App Badge"
    static var description = IntentDescription("Set the badge number on the app icon")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Badge Number", description: "Number to display (0 to clear)")
    var badgeNumber: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Set badge to \(\.$badgeNumber)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = NotificationManager.shared

        guard manager.isAuthorized else {
            throw NotificationError.notAuthorized
        }

        if badgeNumber <= 0 {
            manager.clearBadge()
        } else {
            manager.setBadge(badgeNumber)
        }

        return .result()
    }
}

struct ClearBadgeIntent: AppIntent {
    static var title: LocalizedStringResource = "Clear App Badge"
    static var description = IntentDescription("Remove the badge number from the app icon")

    static var openAppWhenRun: Bool = false

    static var parameterSummary: some ParameterSummary {
        Summary("Clear app badge")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = NotificationManager.shared
        manager.clearBadge()
        return .result()
    }
}

// MARK: - Query Intents

struct GetPendingNotificationsCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Pending Notifications Count"
    static var description = IntentDescription("Get the number of pending scheduled notifications")

    static var openAppWhenRun: Bool = false

    static var parameterSummary: some ParameterSummary {
        Summary("Get pending notifications count")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        let manager = NotificationManager.shared
        await manager.refreshNotificationLists()
        return .result(value: manager.pendingNotifications.count)
    }
}
