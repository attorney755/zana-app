# Zana App — Student Opportunities & Founder Ecosystem Mobile Application

Zana App is a Mobile application designed to connect African students with global opportunities (Scholarships, Internships, Fellowships, Grants, and Engineering roles) and provide startup founders with candidate management tools.

---

## Features Overview

### Student Seeker Portal
- Personalized Opportunity Feed: Filter opportunities by Category (Scholarship, Internship, Fellowship, Engineering, Design), Country (Rwanda, Kenya, Uganda, Ghana, etc.), and Work Type (Remote, On Campus).
- One-Tap Apply: Submit applications with custom cover letters, availability selection, and link attachments (GitHub, LinkedIn).
- Application Status Tracker: Track application status in real-time (Applied, Shortlisted, Accepted, Rejected).
- Real-Time Notifications: Receive alerts when founders update an opportunity, change application status, close or reopen a listing, or send feedback.
- Bookmarks & Saved Opportunities: Save opportunities locally and sync across sessions.
- Multi-Language Support: Flag and language selector supporting English, French, Swahili, and Kinyarwanda.

### Founder & Startup Portal
- Opportunity Publisher: Create, edit, and manage opportunity listings with country eligibility restrictions.
- Candidate Details View: Inspect full applicant profiles, verify country eligibility ("Meets Country Eligibility"), and read short cover letter previews with an expander.
- Direct Candidate Feedback & Reminders: Send custom feedback messages or select pre-populated suggestions (Shortlisted for interview, Document reminders, Reconsidered application).
- Sent Messages History: Persistent log of candidate feedback messages with relative timestamps (Just now, 5m ago, 2h ago, 1d ago), follow-up options, and deletion confirmation.
- Opportunity Lifecycle Management: Close or Reopen opportunities with automated real-time notifications dispatched to all applicants.
- Filtering & Tabs: Filter posts by All, Open Opportunities, or Closed Opportunities with sorting options by Latest or Oldest.

---

## Project Architecture & Structure

```
zana_app/
├── android/                    # Android Native Source & Build Config
├── ios/                        # iOS Native Source & Xcode Project
├── assets/                     # App Images, Icons, and Mock Data
└── lib/
    ├── main.dart               # App Entrypoint & Provider Initialization
    ├── core/
    │   ├── constants/          # App Strings, Colors, Assets, Links
    │   ├── localization/       # Multilingual Translations (EN, FR, SW, RW)
    │   └── theme/              # Light & Dark Mode Design System
    ├── data/
    │   ├── models/             # Data Models (UserModel, OpportunityModel, ApplicationModel, FounderMessageModel)
    │   └── services/           # Firestore, Auth, and Storage Service Handlers
    └── presentation/
        ├── navigation/         # GoRouter Navigation Routes
        ├── screens/
        │   ├── applications/   # Student Application List & Details
        │   ├── auth/           # Login, Sign Up, Password Reset
        │   ├── explore/        # Search & Filter Opportunities
        │   ├── home/           # Student Home Feed
        │   ├── notifications/  # Candidate Notifications Feed
        │   ├── opportunity_detail/ # Opportunity Spec View & Apply Flow
        │   ├── profile/        # Student Profile View
        │   ├── settings/       # App Settings & Dark Mode Toggle
        │   ├── splash/         # Splash Welcome Screen
        │   └── startup/        # Founder Dashboard, Applicants, Messages, Post & Edit
        └── widgets/            # Custom Bottom Navigation Bars, Action Cards, Dialog Modals
```

---

## Prerequisites

Before testing or developing Zana App on a PC, ensure the following software tools are installed:

1. Git: https://git-scm.com/
2. Flutter SDK (^3.12.2 or Flutter 3.x+): https://flutter.dev/docs/get-started/install
3. Dart SDK (Bundled with Flutter SDK)
4. Mobile Platform Tools:
   - Android: Android Studio & Android SDK / Android Virtual Device (AVD Emulator)
   - iOS (macOS only): Xcode 14+ & CocoaPods for iOS Simulator testing

---

## Step-by-Step Installation Guide (By Operating System)

### Windows Installation

1. Install Flutter SDK:
   - Download the Flutter Windows SDK zip file from https://flutter.dev.
   - Extract the package to C:\src\flutter.
   - Add C:\src\flutter\bin to your System PATH environment variables.

2. Configure Android Studio:
   - Install Android Studio from https://developer.android.com/studio.
   - Open Android Studio, install the Android SDK, Command-line Tools, and configure an Virtual Device (Android Emulator).

3. Verify Configuration:
   Open PowerShell or Command Prompt and run:
   ```cmd
   flutter doctor
   ```

4. Clone Repository & Run App:
   ```cmd
   git clone https://github.com/YOUR_GITHUB_USERNAME/zana_app.git
   cd zana_app
   flutter pub get
   flutter run
   ```

---

### macOS Installation

1. Install Flutter SDK:
   Using Homebrew:
   ```bash
   brew install --cask flutter
   ```
   Or extract the SDK manual zip to ~/development/flutter and add to PATH:
   ```bash
   export PATH="$HOME/development/flutter/bin:$PATH"
   ```

2. Configure Xcode for iOS Simulator:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   sudo gem install cocoapods
   ```

3. Verify Setup:
   ```bash
   flutter doctor
   ```

4. Clone Repository & Run App:
   ```bash
   git clone https://github.com/YOUR_GITHUB_USERNAME/zana_app.git
   cd zana_app
   flutter pub get
   flutter run
   ```

---

### Linux (Ubuntu / Debian / Fedora) Installation

1. Install Dependencies & Flutter SDK:
   ```bash
   sudo apt update
   sudo apt install -y git curl unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev
   ```
   Install Flutter via Snap:
   ```bash
   sudo snap install flutter --classic
   ```

2. Configure Android Studio:
   - Download Android Studio for Linux from https://developer.android.com/studio.
   - Set up an Android Virtual Device (Emulator).

3. Verify Setup:
   ```bash
   flutter doctor
   ```

4. Clone Repository & Run App:
   ```bash
   git clone https://github.com/YOUR_GITHUB_USERNAME/zana_app.git
   cd zana_app
   flutter pub get
   flutter run
   ```

---

## Quick Start Command Reference

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_GITHUB_USERNAME/zana_app.git

# 2. Navigate to project folder
cd zana_app

# 3. Fetch dependencies
flutter pub get

# 4. Run on connected Android Emulator / Device
flutter run -d android

# 5. Run on iOS Simulator (macOS only)
flutter run -d ios

# 6. Build Android APK
flutter build apk --release
```

---

## Testing Account Credentials

The application includes built-in mock service fallbacks when database collections are empty:

### Student Account Demo
- Email: student@zana.com
- Password: password123
- Features: Browse feed, apply for opportunities, track status, view notifications.

### Founder Account Demo
- Email: founder@zana.com
- Password: password123
- Features: Dashboard overview, post opportunities, view candidate profiles, send feedback, close or reopen listings.

---

## Useful Flutter Commands

- Hot Reload: Press r in the terminal while app is running.
- Hot Restart: Press R in the terminal while app is running.
- Run Static Analysis:
  ```bash
  flutter analyze
  ```
- Build Android Bundle (AAB):
  ```bash
  flutter build appbundle --release
  ```

---

## License & Attribution

Designed and developed for Zana App Platform. Built using Flutter and Firebase.
