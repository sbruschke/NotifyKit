import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Permission Status")
                        Spacer()
                        Text(notificationManager.isAuthorized ? "Enabled" : "Disabled")
                            .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                    }

                    if !notificationManager.isAuthorized {
                        Button("Open Settings") {
                            openAppSettings()
                        }
                    }
                } header: {
                    Text("Notifications")
                }

                Section {
                    ForEach(NotificationCategory.allCases, id: \.rawValue) { category in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.displayName)
                                .font(.headline)
                            Text(category.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Available Categories")
                } footer: {
                    Text("Categories define the action buttons shown on notifications.")
                }

                Section {
                    ForEach(InterruptionLevel.allCases, id: \.rawValue) { level in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(level.displayName)
                                .font(.headline)
                            Text(level.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Interruption Levels")
                } footer: {
                    Text("Critical notifications require a special Apple entitlement and are not available for sideloaded apps.")
                }

                Section {
                    ForEach(NotificationSound.allCases, id: \.rawValue) { sound in
                        Text(sound.displayName)
                    }
                } header: {
                    Text("Available Sounds")
                } footer: {
                    Text("Custom sounds require adding audio files to the app bundle.")
                }

                Section {
                    Link(destination: URL(string: "https://support.apple.com/guide/shortcuts/welcome/ios")!) {
                        HStack {
                            Text("Shortcuts User Guide")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Help")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(NotificationManager.shared)
}
