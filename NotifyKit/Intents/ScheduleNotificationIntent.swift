import AppIntents
import UserNotifications

struct ScheduleNotificationIntent: AppIntent {
    static var title: LocalizedStringResource = "Schedule Notification"
    static var description = IntentDescription("Schedule a notification for a future time")

    static var openAppWhenRun: Bool = false

    // Required parameters
    @Parameter(title: "Title", description: "The notification title")
    var title: String

    @Parameter(title: "Body", description: "The notification body text")
    var body: String

    // Scheduling parameters
    @Parameter(title: "Date & Time", description: "When to deliver the notification")
    var scheduledDate: Date?

    @Parameter(title: "Delay (seconds)", description: "Seconds from now to deliver (alternative to date)")
    var delaySeconds: Int?

    @Parameter(title: "Repeat", description: "Whether to repeat the notification", default: false)
    var repeats: Bool

    // Optional content parameters
    @Parameter(title: "Subtitle", description: "Optional subtitle shown below the title")
    var subtitle: String?

    @Parameter(title: "Badge Number", description: "Number to show on app icon")
    var badge: Int?

    @Parameter(title: "Sound", description: "Notification sound", default: .default)
    var sound: SoundOption

    @Parameter(title: "Image URL", description: "URL of an image to attach")
    var imageURL: String?

    @Parameter(title: "Thread ID", description: "Group notifications with the same thread ID")
    var threadIdentifier: String?

    @Parameter(title: "Category", description: "Action buttons style", default: .basic)
    var category: CategoryOption

    @Parameter(title: "Interruption Level", description: "How urgently to deliver", default: .active)
    var interruptionLevel: InterruptionLevelOption

    static var parameterSummary: some ParameterSummary {
        Summary("Schedule notification \(\.$title) for \(\.$scheduledDate)") {
            \.$body
            \.$delaySeconds
            \.$repeats
            \.$subtitle
            \.$badge
            \.$sound
            \.$imageURL
            \.$threadIdentifier
            \.$category
            \.$interruptionLevel
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let manager = NotificationManager.shared

        // Check permission
        guard manager.isAuthorized else {
            throw NotificationError.notAuthorized
        }

        // Determine trigger
        var triggerDate: Date? = nil
        var triggerInterval: TimeInterval? = nil

        if let date = scheduledDate {
            guard date > Date() else {
                throw NotificationError.invalidDate
            }
            triggerDate = date
        } else if let delay = delaySeconds, delay > 0 {
            triggerInterval = TimeInterval(delay)
        } else {
            // Default to 1 minute if neither specified
            triggerInterval = 60
        }

        let notificationId = await manager.scheduleNotification(
            title: title,
            body: body,
            subtitle: subtitle,
            badge: badge,
            sound: sound.toNotificationSound,
            imageURL: imageURL,
            threadIdentifier: threadIdentifier,
            categoryIdentifier: category.rawValue,
            interruptionLevel: interruptionLevel.toInterruptionLevel,
            triggerDate: triggerDate,
            triggerInterval: triggerInterval,
            repeats: repeats
        )

        guard let id = notificationId else {
            throw NotificationError.failedToSchedule
        }

        return .result(value: id)
    }
}

// MARK: - Schedule by Interval Intent (Simpler version)

struct ScheduleDelayedNotificationIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Notification After Delay"
    static var description = IntentDescription("Send a notification after a specified delay")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Title")
    var title: String

    @Parameter(title: "Body")
    var body: String

    @Parameter(title: "Delay (minutes)", description: "Minutes from now", default: 5)
    var delayMinutes: Int

    @Parameter(title: "Sound", default: .default)
    var sound: SoundOption

    static var parameterSummary: some ParameterSummary {
        Summary("Send \(\.$title) in \(\.$delayMinutes) minutes") {
            \.$body
            \.$sound
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let manager = NotificationManager.shared

        guard manager.isAuthorized else {
            throw NotificationError.notAuthorized
        }

        let interval = TimeInterval(delayMinutes * 60)

        let notificationId = await manager.scheduleNotification(
            title: title,
            body: body,
            sound: sound.toNotificationSound,
            triggerInterval: interval
        )

        guard let id = notificationId else {
            throw NotificationError.failedToSchedule
        }

        return .result(value: id)
    }
}
