import SwiftUI
import UserNotifications

struct NotificationHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    Text("Pending (\(notificationManager.pendingNotifications.count))").tag(0)
                    Text("Delivered (\(notificationManager.deliveredNotifications.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    pendingList
                } else {
                    deliveredList
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if (selectedTab == 0 && !notificationManager.pendingNotifications.isEmpty) ||
                       (selectedTab == 1 && !notificationManager.deliveredNotifications.isEmpty) {
                        Button("Clear All") {
                            if selectedTab == 0 {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            } else {
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                            }
                            Task {
                                await notificationManager.refreshNotificationLists()
                            }
                        }
                        .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                Task {
                    await notificationManager.refreshNotificationLists()
                }
            }
        }
    }

    private var pendingList: some View {
        Group {
            if notificationManager.pendingNotifications.isEmpty {
                emptyState(
                    icon: "clock",
                    title: "No Pending Notifications",
                    message: "Scheduled notifications will appear here"
                )
            } else {
                List {
                    ForEach(notificationManager.pendingNotifications, id: \.identifier) { request in
                        NotificationRow(
                            title: request.content.title,
                            body: request.content.body,
                            subtitle: request.content.subtitle,
                            identifier: request.identifier,
                            trigger: describeTrigger(request.trigger)
                        )
                    }
                    .onDelete(perform: deletePending)
                }
            }
        }
    }

    private var deliveredList: some View {
        Group {
            if notificationManager.deliveredNotifications.isEmpty {
                emptyState(
                    icon: "bell",
                    title: "No Delivered Notifications",
                    message: "Delivered notifications will appear here"
                )
            } else {
                List {
                    ForEach(notificationManager.deliveredNotifications, id: \.request.identifier) { notification in
                        NotificationRow(
                            title: notification.request.content.title,
                            body: notification.request.content.body,
                            subtitle: notification.request.content.subtitle,
                            identifier: notification.request.identifier,
                            trigger: "Delivered \(formatDate(notification.date))"
                        )
                    }
                    .onDelete(perform: deleteDelivered)
                }
            }
        }
    }

    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func describeTrigger(_ trigger: UNNotificationTrigger?) -> String {
        guard let trigger = trigger else {
            return "Immediate"
        }

        if let calendarTrigger = trigger as? UNCalendarNotificationTrigger {
            if let nextDate = calendarTrigger.nextTriggerDate() {
                return "Scheduled for \(formatDate(nextDate))"
            }
            return "Calendar trigger"
        }

        if let intervalTrigger = trigger as? UNTimeIntervalNotificationTrigger {
            let seconds = Int(intervalTrigger.timeInterval)
            if seconds < 60 {
                return "In \(seconds) seconds"
            } else if seconds < 3600 {
                return "In \(seconds / 60) minutes"
            } else {
                return "In \(seconds / 3600) hours"
            }
        }

        return "Scheduled"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func deletePending(at offsets: IndexSet) {
        let idsToRemove = offsets.map { notificationManager.pendingNotifications[$0].identifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        Task {
            await notificationManager.refreshNotificationLists()
        }
    }

    private func deleteDelivered(at offsets: IndexSet) {
        let idsToRemove = offsets.map { notificationManager.deliveredNotifications[$0].request.identifier }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idsToRemove)
        Task {
            await notificationManager.refreshNotificationLists()
        }
    }
}

struct NotificationRow: View {
    let title: String
    let body: String
    let subtitle: String
    let identifier: String
    let trigger: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(body)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Text(trigger)
                    .font(.caption)
                    .foregroundColor(.blue)

                Spacer()

                Text(identifier.prefix(8) + "...")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotificationHistoryView()
        .environmentObject(NotificationManager.shared)
}
