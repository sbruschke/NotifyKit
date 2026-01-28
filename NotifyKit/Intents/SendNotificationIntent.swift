import AppIntents
import UserNotifications

struct SendNotificationIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Notification"
    static var description = IntentDescription("Send a custom notification immediately")

    static var openAppWhenRun: Bool = false

    // Required parameters
    @Parameter(title: "Title", description: "The notification title")
    var title: String

    @Parameter(title: "Body", description: "The notification body text")
    var body: String

    // Optional parameters
    @Parameter(title: "Subtitle", description: "Optional subtitle shown below the title")
    var subtitle: String?

    @Parameter(title: "Badge Number", description: "Number to show on app icon (0 to clear)")
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

    @Parameter(title: "Relevance Score", description: "Priority for notification summary (0.0 to 1.0)", default: 0.5)
    var relevanceScore: Double

    static var parameterSummary: some ParameterSummary {
        Summary("Send notification with title \(\.$title)") {
            \.$body
            \.$subtitle
            \.$badge
            \.$sound
            \.$imageURL
            \.$threadIdentifier
            \.$category
            \.$interruptionLevel
            \.$relevanceScore
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let manager = NotificationManager.shared

        // Check permission
        guard manager.isAuthorized else {
            throw NotificationError.notAuthorized
        }

        // Validate relevance score
        let validRelevanceScore = min(max(relevanceScore, 0.0), 1.0)

        let success = await manager.sendNotification(
            title: title,
            body: body,
            subtitle: subtitle,
            badge: badge,
            sound: sound.toNotificationSound,
            imageURL: imageURL,
            threadIdentifier: threadIdentifier,
            categoryIdentifier: category.rawValue,
            interruptionLevel: interruptionLevel.toInterruptionLevel,
            relevanceScore: validRelevanceScore
        )

        if !success {
            throw NotificationError.failedToSend
        }

        return .result(value: true)
    }
}

// MARK: - Error Types

enum NotificationError: Error, CustomLocalizedStringResourceConvertible {
    case notAuthorized
    case failedToSend
    case failedToSchedule
    case invalidDate
    case notFound

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notAuthorized:
            return "Notification permission not granted. Please enable notifications in Settings."
        case .failedToSend:
            return "Failed to send notification."
        case .failedToSchedule:
            return "Failed to schedule notification."
        case .invalidDate:
            return "The scheduled date must be in the future."
        case .notFound:
            return "Notification not found."
        }
    }
}
