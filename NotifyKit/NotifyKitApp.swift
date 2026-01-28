import SwiftUI
import UserNotifications

@main
struct NotifyKitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategories()
        return true
    }

    private func registerNotificationCategories() {
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_ACTION",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your reply..."
        )

        let openAction = UNNotificationAction(
            identifier: "OPEN_ACTION",
            title: "Open App",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )

        let markReadAction = UNNotificationAction(
            identifier: "MARK_READ_ACTION",
            title: "Mark as Read",
            options: []
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze (5 min)",
            options: []
        )

        // Category with reply capability
        let interactiveCategory = UNNotificationCategory(
            identifier: "INTERACTIVE",
            actions: [replyAction, openAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Category with quick actions
        let quickActionsCategory = UNNotificationCategory(
            identifier: "QUICK_ACTIONS",
            actions: [markReadAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        // Basic category
        let basicCategory = UNNotificationCategory(
            identifier: "BASIC",
            actions: [openAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        // Reminder category
        let reminderCategory = UNNotificationCategory(
            identifier: "REMINDER",
            actions: [snoozeAction, markReadAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            interactiveCategory,
            quickActionsCategory,
            basicCategory,
            reminderCategory
        ])
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }

    // Handle notification action responses
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        let notification = response.notification

        switch actionIdentifier {
        case "REPLY_ACTION":
            if let textResponse = response as? UNTextInputNotificationResponse {
                handleReply(text: textResponse.userText, notification: notification)
            }
        case "SNOOZE_ACTION":
            snoozeNotification(notification)
        case "MARK_READ_ACTION":
            markAsRead(notification)
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            break
        case UNNotificationDismissActionIdentifier:
            // User dismissed the notification
            break
        default:
            break
        }

        completionHandler()
    }

    private func handleReply(text: String, notification: UNNotification) {
        // Store reply or process it as needed
        print("User replied: \(text)")
    }

    private func snoozeNotification(_ notification: UNNotification) {
        let content = notification.request.content.mutableCopy() as! UNMutableNotificationContent
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func markAsRead(_ notification: UNNotification) {
        // Handle mark as read logic
        print("Marked as read: \(notification.request.identifier)")
    }
}
