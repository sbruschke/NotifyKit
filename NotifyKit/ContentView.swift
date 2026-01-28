import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var testTitle = "Test Notification"
    @State private var testBody = "This is a test notification from NotifyKit"
    @State private var testSubtitle = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Permission Status Card
                    permissionCard

                    // Quick Test Section
                    quickTestSection

                    // Shortcuts Info
                    shortcutsInfoCard

                    // Features List
                    featuresCard
                }
                .padding()
            }
            .navigationTitle("NotifyKit")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingSettings = true }) {
                            Label("Settings", systemImage: "gear")
                        }
                        Button(action: { showingHistory = true }) {
                            Label("History", systemImage: "clock")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showingHistory) {
                NotificationHistoryView()
            }
        }
        .onAppear {
            notificationManager.checkPermissionStatus()
        }
    }

    private var permissionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.title)
                    .foregroundColor(notificationManager.isAuthorized ? .green : .orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Notification Permission")
                        .font(.headline)
                    Text(notificationManager.isAuthorized ? "Enabled" : "Not Enabled")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            if !notificationManager.isAuthorized {
                Button(action: {
                    notificationManager.requestPermission()
                }) {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var quickTestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Test")
                .font(.headline)

            VStack(spacing: 12) {
                TextField("Title", text: $testTitle)
                    .textFieldStyle(.roundedBorder)

                TextField("Subtitle (optional)", text: $testSubtitle)
                    .textFieldStyle(.roundedBorder)

                TextField("Body", text: $testBody)
                    .textFieldStyle(.roundedBorder)
            }

            Button(action: sendTestNotification) {
                HStack {
                    Image(systemName: "bell.badge")
                    Text("Send Test Notification")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(notificationManager.isAuthorized ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!notificationManager.isAuthorized)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var shortcutsInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "apps.iphone")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Shortcuts Integration")
                    .font(.headline)
            }

            Text("NotifyKit adds actions to the Shortcuts app. You can:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                shortcutFeature(icon: "bell.fill", text: "Send instant notifications")
                shortcutFeature(icon: "clock.fill", text: "Schedule future notifications")
                shortcutFeature(icon: "xmark.circle.fill", text: "Cancel pending notifications")
            }

            Button(action: openShortcutsApp) {
                HStack {
                    Image(systemName: "arrow.up.forward.app")
                    Text("Open Shortcuts App")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var featuresCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Customizations")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                featureItem(icon: "textformat", title: "Title & Body")
                featureItem(icon: "text.badge.plus", title: "Subtitle")
                featureItem(icon: "speaker.wave.2", title: "Custom Sound")
                featureItem(icon: "photo", title: "Image Attachment")
                featureItem(icon: "number.circle", title: "Badge Number")
                featureItem(icon: "exclamationmark.bubble", title: "Interruption Level")
                featureItem(icon: "rectangle.stack", title: "Thread Grouping")
                featureItem(icon: "hand.tap", title: "Action Buttons")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private func shortcutFeature(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
        }
    }

    private func featureItem(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .font(.caption)
            Spacer()
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }

    private func sendTestNotification() {
        Task {
            await notificationManager.sendNotification(
                title: testTitle,
                body: testBody,
                subtitle: testSubtitle.isEmpty ? nil : testSubtitle
            )
        }
    }

    private func openShortcutsApp() {
        if let url = URL(string: "shortcuts://") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotificationManager.shared)
}
