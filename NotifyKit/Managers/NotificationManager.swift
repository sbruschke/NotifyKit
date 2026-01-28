import Foundation
import UserNotifications
import UIKit

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    @Published var deliveredNotifications: [UNNotification] = []

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        checkPermissionStatus()
    }

    // MARK: - Permission Management

    func checkPermissionStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            Task { @MainActor in
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert]) { [weak self] granted, error in
            Task { @MainActor in
                self?.isAuthorized = granted
                if let error = error {
                    print("Permission error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Send Notification

    func sendNotification(
        title: String,
        body: String,
        subtitle: String? = nil,
        badge: Int? = nil,
        sound: NotificationSound = .default,
        imageURL: String? = nil,
        threadIdentifier: String? = nil,
        categoryIdentifier: String = "BASIC",
        interruptionLevel: InterruptionLevel = .active,
        relevanceScore: Double = 0.5,
        userInfo: [String: Any] = [:]
    ) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if let subtitle = subtitle, !subtitle.isEmpty {
            content.subtitle = subtitle
        }

        if let badge = badge {
            content.badge = NSNumber(value: badge)
        }

        content.sound = sound.unNotificationSound
        content.categoryIdentifier = categoryIdentifier

        if let threadId = threadIdentifier, !threadId.isEmpty {
            content.threadIdentifier = threadId
        }

        content.interruptionLevel = interruptionLevel.unInterruptionLevel
        content.relevanceScore = relevanceScore

        var mutableUserInfo = userInfo
        mutableUserInfo["createdAt"] = Date().timeIntervalSince1970
        content.userInfo = mutableUserInfo

        // Handle image attachment
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            if let attachment = await downloadAndCreateAttachment(from: url) {
                content.attachments = [attachment]
            }
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate delivery
        )

        do {
            try await notificationCenter.add(request)
            await refreshNotificationLists()
            return true
        } catch {
            print("Failed to send notification: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Schedule Notification

    func scheduleNotification(
        title: String,
        body: String,
        subtitle: String? = nil,
        badge: Int? = nil,
        sound: NotificationSound = .default,
        imageURL: String? = nil,
        threadIdentifier: String? = nil,
        categoryIdentifier: String = "BASIC",
        interruptionLevel: InterruptionLevel = .active,
        relevanceScore: Double = 0.5,
        triggerDate: Date? = nil,
        triggerInterval: TimeInterval? = nil,
        repeats: Bool = false,
        userInfo: [String: Any] = [:]
    ) async -> String? {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if let subtitle = subtitle, !subtitle.isEmpty {
            content.subtitle = subtitle
        }

        if let badge = badge {
            content.badge = NSNumber(value: badge)
        }

        content.sound = sound.unNotificationSound
        content.categoryIdentifier = categoryIdentifier

        if let threadId = threadIdentifier, !threadId.isEmpty {
            content.threadIdentifier = threadId
        }

        content.interruptionLevel = interruptionLevel.unInterruptionLevel
        content.relevanceScore = relevanceScore

        var mutableUserInfo = userInfo
        mutableUserInfo["createdAt"] = Date().timeIntervalSince1970
        content.userInfo = mutableUserInfo

        // Handle image attachment
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            if let attachment = await downloadAndCreateAttachment(from: url) {
                content.attachments = [attachment]
            }
        }

        // Create trigger
        let trigger: UNNotificationTrigger?

        if let date = triggerDate {
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: date
            )
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        } else if let interval = triggerInterval, interval > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
        } else {
            trigger = nil
        }

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            await refreshNotificationLists()
            return identifier
        } catch {
            print("Failed to schedule notification: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Cancel Notifications

    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        Task {
            await refreshNotificationLists()
        }
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        Task {
            await refreshNotificationLists()
        }
    }

    func cancelNotificationsByThread(threadIdentifier: String) async {
        let pending = await notificationCenter.pendingNotificationRequests()
        let idsToRemove = pending
            .filter { $0.content.threadIdentifier == threadIdentifier }
            .map { $0.identifier }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: idsToRemove)
        await refreshNotificationLists()
    }

    // MARK: - Badge Management

    func setBadge(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Notification Lists

    func refreshNotificationLists() async {
        let pending = await notificationCenter.pendingNotificationRequests()
        let delivered = await notificationCenter.deliveredNotifications()

        await MainActor.run {
            self.pendingNotifications = pending
            self.deliveredNotifications = delivered
        }
    }

    // MARK: - Helpers

    private func downloadAndCreateAttachment(from url: URL) async -> UNNotificationAttachment? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }

            // Determine file extension from MIME type or URL
            let fileExtension: String
            if let mimeType = httpResponse.mimeType {
                switch mimeType {
                case "image/jpeg": fileExtension = "jpg"
                case "image/png": fileExtension = "png"
                case "image/gif": fileExtension = "gif"
                case "image/webp": fileExtension = "webp"
                default: fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
                }
            } else {
                fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
            }

            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = "\(UUID().uuidString).\(fileExtension)"
            let fileURL = tempDirectory.appendingPathComponent(fileName)

            try data.write(to: fileURL)

            let attachment = try UNNotificationAttachment(
                identifier: UUID().uuidString,
                url: fileURL,
                options: nil
            )

            return attachment
        } catch {
            print("Failed to create attachment: \(error.localizedDescription)")
            return nil
        }
    }
}
