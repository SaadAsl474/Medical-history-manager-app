# My Medical History - Flutter Mobile Application

A production-grade, offline-first mobile healthcare application built in **Flutter & Dart** based on the **Clinical Clarity** design language. It allows users to store, manage, search, and synchronize their lifelong medical records with **Google Drive**.

---

## 🏛 Architecture & Data Structure

```text
User
└── Doctors (Created Once, Persistent)
    └── Multiple Medical Visits (Unlimited visits per doctor)
        ├── Prescribed Medicines (Dosage, Frequency, Duration, Instructions)
        ├── Diagnostic Tests (Test Name, Date, Result Notes, Status)
        ├── Attachments & Prescriptions (Camera Capture, Photos, PDF Reports)
        └── Follow-Up Dates & Doctor Notes
```

### Key Principles:
1. **One-Time Doctor Profile Creation**: Doctor profiles (name, specialty, contact, hospital, GPS pin) are created once and hold unlimited visits over many years.
2. **Independent Visit Deletion**: Deleting a medical visit never deletes the parent doctor profile.
3. **Offline-First Resilience**: All doctors, visits, medicines, tests, and attachments are persisted immediately in a local SQLite database (`sqflite`). Edits and creations are queued.
4. **Google Drive Cloud Sync**: When connected to the internet, the app automatically creates/locates `MyMedicalHistory_Backup` in the user's Google Drive and synchronizes data.
5. **Global Multi-Field Search**: Instant search across Doctor names, Hospital names, Diagnoses, Symptoms, Medicine names (e.g. searching *"Panadol"* shows all visits where Panadol was prescribed), and Test names.
6. **Biometric Security & App Lock**: 4-digit PIN code + Fingerprint / Face ID biometric gatekeeper.

---

## 📁 Project Structure

```text
lib/
├── main.dart                               # Entry point, MultiProvider & RootGatekeeper
├── core/
│   ├── constants/
│   │   └── app_colors.dart                 # Clinical Clarity color tokens
│   ├── database/
│   │   └── database_helper.dart            # SQLite DB (Doctors, Visits, Cascade relations)
│   ├── services/
│   │   ├── auth_service.dart               # Google Sign-In & Auth state
│   │   ├── google_drive_service.dart       # Drive API, Backup folder, Upload & Restore
│   │   ├── location_service.dart           # GPS coordinates & Google Maps launcher
│   │   ├── security_service.dart           # Biometrics (local_auth) & Secure PIN storage
│   │   └── sync_manager.dart               # Connectivity monitoring & Auto-Sync engine
│   └── theme/
│       └── app_theme.dart                  # Material 3 & Plus Jakarta Sans typography
├── models/
│   ├── attachment_model.dart               # Photos, PDF reports, prescriptions
│   ├── doctor_model.dart                   # Doctor and Hospital details
│   ├── medical_test_model.dart             # Lab tests and diagnostic checks
│   ├── medicine_model.dart                 # Prescribed drugs, dosage, frequency
│   ├── user_profile_model.dart             # User profile & Drive sync state
│   └── visit_model.dart                    # Relational Visit model
├── providers/
│   ├── auth_provider.dart                  # User authentication state
│   ├── medical_provider.dart               # Doctors, Visits, Search & Filter state
│   └── security_provider.dart              # App Lock PIN & Biometrics state
├── screens/
│   ├── auth/
│   │   ├── app_lock_screen.dart            # Keypad PIN & Fingerprint screen
│   │   └── login_screen.dart               # Google Sign-in & Drive permission consent
│   ├── backup/
│   │   └── backup_sync_screen.dart         # Drive Sync, JSON Export/Restore, PIN Settings
│   ├── dashboard/
│   │   └── home_dashboard_screen.dart      # Stitch Home Dashboard with Quick Stats
│   ├── doctors/
│   │   ├── add_edit_doctor_screen.dart     # Doctor & Hospital creation with GPS
│   │   ├── doctor_profile_screen.dart      # Doctor details & chronological visit history
│   │   └── doctors_directory_screen.dart   # Filterable doctors catalog
│   ├── main_shell.dart                     # Bottom Navigation Bar
│   ├── search/
│   │   └── global_search_screen.dart       # Global multi-entity search & filter chips
│   └── visits/
│       ├── add_edit_visit_screen.dart      # Complete medical visit logger
│       ├── visit_detail_screen.dart        # Full record inspection, edit, delete
│       └── visit_timeline_screen.dart      # Chronological medical timeline
└── widgets/
    ├── doctor_card.dart                    # Doctor card with visit counter & actions
    ├── empty_state_view.dart               # Visual feedback for empty states
    ├── stat_card.dart                      # Metric cards (Doctors, Visits, Meds, Reports)
    ├── sync_status_badge.dart              # Google Drive status pill ("Synced 10m ago")
    └── visit_card.dart                     # Visit card with prescription preview
```

---

## 🚀 How to Run the App

1. Make sure Flutter SDK is installed on your computer:
   ```bash
   flutter doctor
   ```

2. Navigate to this directory and install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on your connected device, emulator, or Chrome:
   ```bash
   flutter run
   ```

---

## 🔑 Google Sign-In & Google Drive Setup

To enable live Google Sign-In and Google Drive Cloud Sync on Android/iOS:
1. Create a project in [Google Cloud Console](https://console.cloud.google.com/).
2. Enable the **Google Drive API**.
3. Configure the **OAuth Consent Screen** and add the scopes:
   - `https://www.googleapis.com/auth/drive.file`
   - `https://www.googleapis.com/auth/drive.appdata`
4. Download and add `google-services.json` to `android/app/` (for Android) or `GoogleService-Info.plist` (for iOS).
*(Note: A built-in Demo / Offline mode is included so the app is immediately testable without OAuth credentials!)*
