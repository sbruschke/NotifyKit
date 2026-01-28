import Foundation
import UserNotifications
import AppIntents

// MARK: - Sound Options

enum NotificationSound: String, CaseIterable, Codable {
    case `default` = "default"
    case none = "none"
    case tritone = "tritone"
    case chime = "chime"
    case glass = "glass"
    case horn = "horn"
    case bell = "bell"
    case electronic = "electronic"

    var displayName: String {
        switch self {
        case .default: return "Default"
        case .none: return "None (Silent)"
        case .tritone: return "Tri-tone"
        case .chime: return "Chime"
        case .glass: return "Glass"
        case .horn: return "Horn"
        case .bell: return "Bell"
        case .electronic: return "Electronic"
        }
    }

    var unNotificationSound: UNNotificationSound? {
        switch self {
        case .default: return .default
        case .none: return nil
        case .tritone: return UNNotificationSound(named: UNNotificationSoundName("tri-tone.caf"))
        case .chime: return UNNotificationSound(named: UNNotificationSoundName("chime.caf"))
        case .glass: return UNNotificationSound(named: UNNotificationSoundName("glass.caf"))
        case .horn: return UNNotificationSound(named: UNNotificationSoundName("horn.caf"))
        case .bell: return UNNotificationSound(named: UNNotificationSoundName("bell.caf"))
        case .electronic: return UNNotificationSound(named: UNNotificationSoundName("electronic.caf"))
        }
    }
}

// MARK: - App Intent Sound Enum

enum SoundOption: String, AppEnum {
    case `default` = "default"
    case none = "none"
    case tritone = "tritone"
    case chime = "chime"
    case glass = "glass"
    case horn = "horn"
    case bell = "bell"
    case electronic = "electronic"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Sound")
    }

    static var caseDisplayRepresentations: [SoundOption: DisplayRepresentation] {
        [
            .default: DisplayRepresentation(title: "Default"),
            .none: DisplayRepresentation(title: "None (Silent)"),
            .tritone: DisplayRepresentation(title: "Tri-tone"),
            .chime: DisplayRepresentation(title: "Chime"),
            .glass: DisplayRepresentation(title: "Glass"),
            .horn: DisplayRepresentation(title: "Horn"),
            .bell: DisplayRepresentation(title: "Bell"),
            .electronic: DisplayRepresentation(title: "Electronic")
        ]
    }

    var toNotificationSound: NotificationSound {
        NotificationSound(rawValue: self.rawValue) ?? .default
    }
}

// MARK: - Interruption Level

enum InterruptionLevel: String, CaseIterable, Codable {
    case passive = "passive"
    case active = "active"
    case timeSensitive = "timeSensitive"
    case critical = "critical"

    var displayName: String {
        switch self {
        case .passive: return "Passive (Silent)"
        case .active: return "Active (Normal)"
        case .timeSensitive: return "Time Sensitive"
        case .critical: return "Critical"
        }
    }

    var description: String {
        switch self {
        case .passive: return "Delivered quietly, no sound or vibration"
        case .active: return "Normal notification with sound"
        case .timeSensitive: return "Breaks through Focus modes"
        case .critical: return "Bypasses all settings (requires entitlement)"
        }
    }

    var unInterruptionLevel: UNNotificationInterruptionLevel {
        switch self {
        case .passive: return .passive
        case .active: return .active
        case .timeSensitive: return .timeSensitive
        case .critical: return .critical
        }
    }
}

// MARK: - App Intent Interruption Level Enum

enum InterruptionLevelOption: String, AppEnum {
    case passive = "passive"
    case active = "active"
    case timeSensitive = "timeSensitive"
    case critical = "critical"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Interruption Level")
    }

    static var caseDisplayRepresentations: [InterruptionLevelOption: DisplayRepresentation] {
        [
            .passive: DisplayRepresentation(title: "Passive", subtitle: "Silent delivery"),
            .active: DisplayRepresentation(title: "Active", subtitle: "Normal notification"),
            .timeSensitive: DisplayRepresentation(title: "Time Sensitive", subtitle: "Breaks through Focus"),
            .critical: DisplayRepresentation(title: "Critical", subtitle: "Bypasses all settings")
        ]
    }

    var toInterruptionLevel: InterruptionLevel {
        InterruptionLevel(rawValue: self.rawValue) ?? .active
    }
}

// MARK: - Notification Category

enum NotificationCategory: String, CaseIterable, Codable {
    case basic = "BASIC"
    case interactive = "INTERACTIVE"
    case quickActions = "QUICK_ACTIONS"
    case reminder = "REMINDER"

    var displayName: String {
        switch self {
        case .basic: return "Basic"
        case .interactive: return "Interactive (with Reply)"
        case .quickActions: return "Quick Actions"
        case .reminder: return "Reminder"
        }
    }

    var description: String {
        switch self {
        case .basic: return "Open and Dismiss buttons"
        case .interactive: return "Reply, Open, and Dismiss buttons"
        case .quickActions: return "Mark Read, Snooze, and Dismiss"
        case .reminder: return "Snooze, Mark Read, and Dismiss"
        }
    }
}

// MARK: - App Intent Category Enum

enum CategoryOption: String, AppEnum {
    case basic = "BASIC"
    case interactive = "INTERACTIVE"
    case quickActions = "QUICK_ACTIONS"
    case reminder = "REMINDER"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Category")
    }

    static var caseDisplayRepresentations: [CategoryOption: DisplayRepresentation] {
        [
            .basic: DisplayRepresentation(title: "Basic", subtitle: "Open & Dismiss"),
            .interactive: DisplayRepresentation(title: "Interactive", subtitle: "Reply, Open, Dismiss"),
            .quickActions: DisplayRepresentation(title: "Quick Actions", subtitle: "Mark Read, Snooze, Dismiss"),
            .reminder: DisplayRepresentation(title: "Reminder", subtitle: "Snooze, Mark Read, Dismiss")
        ]
    }
}

// MARK: - Stored Notification (for history)

struct StoredNotification: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let subtitle: String?
    let createdAt: Date
    let scheduledFor: Date?
    let threadIdentifier: String?
    let category: String
    var wasDelivered: Bool

    init(from request: UNNotificationRequest, scheduledFor: Date? = nil) {
        self.id = request.identifier
        self.title = request.content.title
        self.body = request.content.body
        self.subtitle = request.content.subtitle.isEmpty ? nil : request.content.subtitle
        self.createdAt = Date()
        self.scheduledFor = scheduledFor
        self.threadIdentifier = request.content.threadIdentifier.isEmpty ? nil : request.content.threadIdentifier
        self.category = request.content.categoryIdentifier
        self.wasDelivered = false
    }
}
