# Zana App — Android Mobile Application

Zana App is an Android mobile application built with Flutter and Firebase. It provides a dual-portal ecosystem connecting African students with global opportunities (Scholarships, Internships, Fellowships, Grants, and Engineering roles) while offering startup founders candidate management and direct feedback tools.

Repository: https://github.com/attorney755/zana-app

---

## Features Overview

### Student Seeker Portal
- Opportunity Feed: Browse and filter listings by Category (Scholarship, Internship, Fellowship, Engineering, Design), Country (Rwanda, Kenya, Uganda, Ghana, etc.), and Work Type (Remote, On Campus).
- One-Tap Application: Apply directly with custom cover letters, availability selection, and professional links (GitHub, LinkedIn).
- Real-Time Application Tracker: Monitor application status (Applied, Shortlisted, Accepted, Rejected).
- Automated Candidate Notifications: Receive alerts when founders update opportunities, change application status, close/reopen posts, or send feedback.
- Bookmarks & Saved Opportunities: Save opportunities for offline access and future review.
- Multilingual Support: Switch interface language between English, French, Swahili, and Kinyarwanda.

### Founder & Startup Portal
- Opportunity Publishing: Create, edit, and post listings with country eligibility limits.
- Applicant Management: Inspect applicant profiles, verify country eligibility ("Meets Country Eligibility"), and read short cover letter previews with an expander.
- Direct Feedback & Follow-Ups: Send candidate feedback messages or select preset suggestions (Shortlisted for interview, Document reminders, Reconsidered application).
- Sent Messages Log: Access a persistent log of sent candidate messages with relative time badges (Just now, 5m ago, 2h ago, 1d ago), follow-up options, and confirmation deletion.
- Opportunity Lifecycle Control: Close or Reopen opportunities with automated real-time notifications dispatched to all applicants.
- Filtering & Sorting: Filter posts by All, Open Opportunities, or Closed Opportunities and sort by Latest or Oldest.

---

## Project Folder Structure

```
zana_app/
├── android/                    # Android Native Configuration & Build Setup
├── assets/                     # App Images, Graphics, and Mock Files
└── lib/
    ├── main.dart               # App Entrypoint & Provider Setup
    ├── firebase_options.dart   # Firebase Environment Options
    ├── core/
    │   ├── constants/          # Application Color Tokens & Constants
    │   ├── localization/       # Multilingual Translations (EN, FR, SW, RW)
    │   └── theme/              # Light & Dark Mode Design System
    ├── data/
    │   ├── models/             # Data Schemas (UserModel, OpportunityModel, ApplicationModel, FounderMessageModel)
    │   └── services/           # Firestore Database, Auth, and Notification Handlers
    └── presentation/
        ├── navigation/         # GoRouter App Navigation Configuration
        ├── screens/
        │   ├── applications/   # Student Application List Screen
        │   ├── auth/           # Login, Sign Up, and Password Reset Screens
        │   ├── explore/        # Opportunity Search & Filter Screen
        │   ├── home/           # Student Feed Screen
        │   ├── notifications/  # Candidate Notifications Feed
        │   ├── opportunity_detail/ # Opportunity Spec & Apply Screen
        │   ├── profile/        # Student Profile Screen
        │   ├── settings/       # App Settings & Dark Mode Toggle
        │   ├── splash/         # Welcome Splash Screen
        │   └── startup/        # Founder Dashboard, Applicants, Messages, Post & Edit Screens
        └── widgets/            # Custom Navigation Bars, Action Cards, Dialog Modals
```

---

## Prerequisites & Required Software

To test and run Zana App on a local development PC, install the following software:

1. Git CLI: https://git-scm.com/
2. Flutter SDK (Version 3.12.2 or higher): https://flutter.dev/docs/get-started/install
3. Java Development Kit (JDK 17): Included with Android Studio or downloaded separately.
4. Android Studio: https://developer.android.com/studio
   - Android SDK Build-Tools
   - Android Command-line Tools
   - Android Virtual Device (AVD Emulator) or a physical Android phone with USB Debugging enabled.
5. A Google Firebase Account: https://console.firebase.google.com/

---

## Firebase Setup Guide (Database & Authentication Setup)

To test the application locally with a database backend, you must create a Firebase project and connect it to your local environment.

### Step 1: Create a Firebase Project
1. Go to the Firebase Console: https://console.firebase.google.com/
2. Click "Add project" and name it `zana-app` (or your preferred name).
3. Disable or enable Google Analytics as desired, then click "Create project".

### Step 2: Enable Firebase Authentication
1. In the Firebase Console sidebar, select "Build" > "Authentication".
2. Click "Get started".
3. Under "Sign-in method", select "Email/Password".
4. Enable "Email/Password" and click "Save".

### Step 3: Create Cloud Firestore Database
1. In the Firebase Console sidebar, select "Build" > "Firestore Database".
2. Click "Create database".
3. Choose a location close to your region and click "Next".
4. Select "Start in test mode" (or set your security rules) and click "Create".
5. In the "Rules" tab of Firestore, set the rules to allow read and write access during local development:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```
6. Click "Publish".

### Step 4: Register Android Application & Download Config
1. In Project Settings (gear icon in the top left), select "Add app" and choose "Android".
2. Register the Android Package Name (check `android/app/build.gradle` for your applicationId, default: `com.example.zana_app`).
3. Download the `google-services.json` configuration file.
4. Place the downloaded `google-services.json` file inside your project directory at:
   `zana_app/android/app/google-services.json`

---

## Step-by-Step Setup Guide (By Operating System)

### Operating System 1: Windows Setup

1. Install Flutter SDK:
   - Download the Flutter Windows SDK zip file from https://flutter.dev.
   - Extract the zip folder to `C:\src\flutter`.
   - Add `C:\src\flutter\bin` to your User and System PATH environment variables.

2. Install Android Studio & Setup Emulator:
   - Install Android Studio from https://developer.android.com/studio.
   - Open Android Studio, go to More Actions > Virtual Device Manager, and create an Android Virtual Device (AVD).

3. Verify Setup:
   Open PowerShell or Command Prompt and execute:
   ```cmd
   flutter doctor
   ```

4. Clone Repository & Run App:
   ```cmd
   git clone https://github.com/attorney755/zana-app.git
   cd zana-app
   flutter pub get
   flutter run -d android
   ```

---

### Operating System 2: macOS Setup

1. Install Flutter SDK:
   Using Homebrew:
   ```bash
   brew install --cask flutter
   ```
   Or extract the SDK manual archive to `~/development/flutter` and export PATH:
   ```bash
   export PATH="$HOME/development/flutter/bin:$PATH"
   ```

2. Setup Android Studio & Emulator:
   - Install Android Studio for Mac.
   - Open Device Manager and create an Android Virtual Device (ARM64 / x86_64).

3. Verify Setup:
   ```bash
   flutter doctor
   ```

4. Clone Repository & Run App:
   ```bash
   git clone https://github.com/attorney755/zana-app.git
   cd zana-app
   flutter pub get
   flutter run -d android
   ```

---

### Operating System 3: Linux (Ubuntu / Debian / Fedora) Setup

1. Install System Dependencies:
   ```bash
   sudo apt update
   sudo apt install -y git curl unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev openjdk-17-jdk
   ```

2. Install Flutter SDK:
   ```bash
   sudo snap install flutter --classic
   ```

3. Setup Android Studio & KVM Acceleration:
   - Download and install Android Studio for Linux.
   - Enable KVM for hardware acceleration:
     ```bash
     sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
     sudo adduser $USER kvm
     ```

4. Verify Setup:
   ```bash
   flutter doctor
   ```

5. Clone Repository & Run App:
   ```bash
   git clone https://github.com/attorney755/zana-app.git
   cd zana-app
   flutter pub get
   flutter run -d android
   ```

---

## Troubleshooting Guide & Common Setup Issues

### Issue 1: `google-services.json` Missing Error
- Error Trace: `File google-services.json is missing from module root folder.`
- Cause: The Firebase Android configuration file is not placed in the correct location.
- Solution: Ensure you download `google-services.json` from Firebase Console and copy it directly to `zana_app/android/app/google-services.json`.

---

### Issue 2: Android Licenses Not Accepted
- Error Trace: `Android sdkmanager tool not found` or `Android licenses not accepted.`
- Cause: Android SDK build tools licenses have not been accepted yet.
- Solution: Open terminal and execute:
  ```bash
  flutter doctor --android-licenses
  ```
  Press `y` to accept all pending license agreements.

---

### Issue 3: Java / Gradle Version Mismatch or `JAVA_HOME` Not Set
- Error Trace: `Unsupported class file major version` or `JAVA_HOME is set to an invalid directory.`
- Cause: Gradle requires JDK 17 to run Android builds cleanly.
- Solution:
  1. Open Android Studio Settings > Build, Execution, Deployment > Build Tools > Gradle.
  2. Set Gradle JDK to `Embedded JDK` or `JDK 17`.
  3. Set `JAVA_HOME` environment variable to your JDK 17 path (e.g. `C:\Program Files\Android\Android Studio\jbr` on Windows).

---

### Issue 4: Android Device / Emulator Not Detected
- Error Trace: `No supported devices connected` or `Unable to locate adb.`
- Cause: ADB daemon is not running or USB debugging is disabled on physical phone.
- Solution:
  1. For Physical Devices: Enable "Developer Options" on phone, turn on "USB Debugging", and authorize your computer.
  2. For Emulators: Restart ADB server using command:
     ```bash
     adb kill-server
     adb start-server
     flutter devices
     ```

---

### Issue 5: Firestore Permission Denied Error (`PERMISSION_DENIED`)
- Error Trace: `[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.`
- Cause: Cloud Firestore security rules are blocking unauthenticated reads or writes.
- Solution: Go to Firebase Console > Firestore Database > Rules, set rules to allow read/write in development mode, and click "Publish":
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if true;
      }
    }
  }
  ```

---

### Issue 6: Gradle Build Failure or Corrupted Build Cache
- Error Trace: `Could not resolve all files for configuration` or build hangs.
- Cause: Stale build artifacts or network interruption during Gradle dependency download.
- Solution: Run clean build commands:
  ```bash
  flutter clean
  cd android
  ./gradlew clean
  cd ..
  flutter pub get
  flutter run -d android
  ```

---

## Account Registration & Testing Guide

Once the application is connected to Cloud Firestore, users create new accounts directly within the app during testing.

### Student Account Registration
- Navigate to the Sign Up screen and select "Student".
- Fill in your full name, email (e.g. `student@example.com`), and password.
- Complete the onboarding steps to set up your profile details (Field of Study, Country, Education Level).

### Startup / Founder Account Registration
- Navigate to the Sign Up screen and select "Startup Founder".
- Register using a business email address (e.g. `zana@info.tech` or `founder@company.io`) and business name.
- Note: Business email format is validated during startup registration. Email link verification is not required for testing, so any valid business email format (e.g. `info@company.tech`) can be used for testing.

---

## Useful Command Quick Reference

- Run App on Android Device / Emulator:
  ```bash
  flutter run -d android
  ```
- Trigger Hot Reload: Press `r` in the running terminal.
- Trigger Hot Restart: Press `R` in the running terminal.
- Run Static Code Analysis:
  ```bash
  flutter analyze
  ```

---

## License & Attribution

Designed and developed for Zana App Platform. Built using Flutter and Firebase.
