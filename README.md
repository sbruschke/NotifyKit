# NotifyKit

A sideloadable iOS app that integrates with Shortcuts to send fully customizable notifications.

## Features

### Notification Customization
- **Title, Subtitle, Body** - Full text customization
- **Badge Number** - Set or clear app icon badge
- **Sound** - Default, silent, or system sounds
- **Image Attachments** - Attach images from URLs
- **Thread Grouping** - Group related notifications together
- **Interruption Levels** - Passive, Active, Time Sensitive, Critical
- **Relevance Score** - Priority in notification summary
- **Action Buttons** - Reply, Snooze, Mark as Read, Dismiss

### Shortcuts Actions
| Action | Description |
|--------|-------------|
| Send Notification | Send immediately with full customization |
| Schedule Notification | Schedule for a specific date/time |
| Send Notification After Delay | Send after X minutes |
| Cancel Notification | Cancel by ID |
| Cancel All Notifications | Clear all pending and delivered |
| Cancel Notifications by Thread | Clear a notification group |
| Set App Badge | Set badge number |
| Clear App Badge | Remove badge |
| Get Pending Count | Count scheduled notifications |

## Setup Instructions

### 1. Create a GitHub Repository

1. Go to [github.com](https://github.com) and sign in (or create an account)
2. Click **New repository**
3. Name it `NotifyKit` (or whatever you prefer)
4. Set visibility to **Public** (for unlimited free builds)
5. Click **Create repository**

### 2. Upload the Code

**Option A: Using GitHub Web Interface**
1. In your new repository, click **uploading an existing file**
2. Drag the entire `NotifyKit` folder contents into the browser
3. Click **Commit changes**

**Option B: Using Git (if you have it installed)**
```bash
cd NotifyKit
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/NotifyKit.git
git push -u origin main
```

### 3. Build the IPA

1. Go to your repository on GitHub
2. Click the **Actions** tab
3. You should see the "Build IPA" workflow
4. If it hasn't run automatically, click **Run workflow** > **Run workflow**
5. Wait for the build to complete (5-10 minutes)
6. Click on the completed workflow run
7. Scroll down to **Artifacts**
8. Download **NotifyKit-IPA**

### 4. Sideload the IPA

**Using AltStore:**
1. Install [AltStore](https://altstore.io/) on your device
2. Open the downloaded `.ipa` file
3. Choose "Open with AltStore"
4. The app will be signed and installed

**Using Sideloadly:**
1. Download [Sideloadly](https://sideloadly.io/)
2. Connect your iOS device
3. Drag the `.ipa` file into Sideloadly
4. Enter your Apple ID
5. Click Start

### 5. Enable Notifications

1. Open NotifyKit on your device
2. Tap **Enable Notifications** when prompted
3. The app is now ready to use with Shortcuts

## Using with Shortcuts

1. Open the **Shortcuts** app
2. Create a new shortcut
3. Tap **Add Action**
4. Search for "NotifyKit"
5. Choose an action (e.g., "Send Notification")
6. Configure the parameters
7. Run the shortcut

### Example Shortcuts

**Morning Reminder:**
```
Send Notification with NotifyKit
  Title: Good Morning!
  Body: Time to start your day
  Sound: Chime
  Interruption Level: Time Sensitive
```

**Low Battery Alert:**
```
Get Battery Level
If Battery Level < 20
  Send Notification with NotifyKit
    Title: Low Battery
    Body: Battery at {Battery Level}%
    Badge: 1
```

**Scheduled Reminder:**
```
Schedule Notification with NotifyKit
  Title: Meeting Reminder
  Body: Your meeting starts in 15 minutes
  Date: [Date Input]
```

## Customization Options

### Interruption Levels

| Level | Behavior |
|-------|----------|
| Passive | Delivered silently, no sound or vibration |
| Active | Normal notification with sound |
| Time Sensitive | Breaks through Focus modes |
| Critical | Bypasses all settings (requires entitlement) |

### Categories (Action Buttons)

| Category | Buttons |
|----------|---------|
| Basic | Open, Dismiss |
| Interactive | Reply, Open, Dismiss |
| Quick Actions | Mark Read, Snooze (5 min), Dismiss |
| Reminder | Snooze, Mark Read, Dismiss |

## Troubleshooting

**Build fails with signing error:**
- This is expected - the build creates an unsigned IPA
- AltStore/Sideloadly will sign it with your Apple ID

**Notifications not appearing:**
- Check notification permissions in iOS Settings
- Ensure Focus mode isn't blocking them
- Try sending with "Time Sensitive" interruption level

**Shortcuts can't find NotifyKit actions:**
- Open NotifyKit at least once
- Force close and reopen Shortcuts app
- Restart your device

**App expires after 7 days:**
- Free Apple IDs require re-signing every 7 days
- Use AltStore's background refresh feature
- Or get an Apple Developer account ($99/year) for 1-year signing

## Requirements

- iOS 16.0 or later
- iPhone or iPad
- Shortcuts app

## Privacy

NotifyKit:
- Does not collect any data
- Does not require internet (except for image attachments)
- All notifications are processed locally
- No analytics or tracking

## License

MIT License - Feel free to modify and distribute.
