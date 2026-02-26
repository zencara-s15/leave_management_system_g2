# Leave Management System — Group 2

A Flutter mobile application for managing employee leave requests.
No backend or database required — all data is stored locally as JSON using `SharedPreferences`.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Clone the Repository](#2-clone-the-repository)
3. [Install Dependencies](#3-install-dependencies)
4. [Run the App](#4-run-the-app)
5. [Demo Accounts](#5-demo-accounts)
6. [Features](#6-features)
7. [Project Structure](#7-project-structure)
8. [Packages Used](#8-packages-used)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

Make sure every team member has the following installed **before** cloning.

### Flutter SDK
This project requires **Flutter 3.38.3** and **Dart 3.10.1** (or higher, same major).

```bash
# Check your current version
flutter --version
```

If Flutter is not installed, follow the official guide:
https://docs.flutter.dev/get-started/install

After installing, run the Flutter doctor to verify your setup:

```bash
flutter doctor
```

All items should show a green checkmark (✓). Pay attention to:
- **Android toolchain** — needed to run on Android emulator / physical device
- **Connected device** — at least one device or emulator must be available

### Required Tools
| Tool | Minimum Version | Download |
|------|----------------|----------|
| Flutter SDK | 3.38.x | https://docs.flutter.dev/get-started/install |
| Dart SDK | 3.10.1 | Bundled with Flutter |
| Android Studio | 2023.x+ | https://developer.android.com/studio |
| Java JDK | 17+ | Bundled with Android Studio |
| Git | Any | https://git-scm.com/downloads |

> **VS Code users:** Install the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) and [Dart extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code).

---

## 2. Clone the Repository

Open a terminal and run:

```bash
git clone https://github.com/zencara-s15/leave_management_system_g2.git
```

Then navigate into the project folder:

```bash
cd leave_management_system_g2
```

---

## 3. Install Dependencies

Install all required packages by running:

```bash
flutter pub get
```

You should see output like:

```
Resolving dependencies...
Got dependencies!
```

> **Note:** You do NOT need to set up a database, backend server, or `.env` file.
> The app uses `SharedPreferences` for local JSON storage. Everything works out of the box.

---

## 4. Run the App

### Step 1 — Start a device

**Option A: Android Emulator**
1. Open Android Studio
2. Go to **Device Manager** (right side panel or Tools → Device Manager)
3. Click **Play (▶)** next to your virtual device to launch it

**Option B: Physical Android Device**
1. Enable **Developer Options** on your phone
   - Go to **Settings → About Phone** → Tap **Build Number** 7 times
2. Enable **USB Debugging** inside Developer Options
3. Connect the phone via USB cable
4. When prompted on your phone, tap **Allow USB Debugging**

### Step 2 — Verify the device is detected

```bash
flutter devices
```

You should see your emulator or device listed, for example:
```
sdk gphone x86 arm (mobile) • emulator-5554 • android-x86
```

### Step 3 — Run the app

```bash
flutter run
```

To run on a specific device (if you have more than one connected):

```bash
# List devices first
flutter devices

# Then run on a specific device ID
flutter run -d emulator-5554
```

### Step 4 — Hot reload & Hot restart (while the app is running)

| Action | Key |
|--------|-----|
| Hot Reload (keeps state) | Press `r` in the terminal |
| Hot Restart (resets state) | Press `R` in the terminal |
| Quit | Press `q` in the terminal |

---

## 5. Demo Accounts

On **first launch**, the app automatically seeds demo accounts. Use these to log in:

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@company.com` | `admin123` |
| Manager | `manager@company.com` | `manager123` |
| Employee | `john@company.com` | `emp123` |
| Employee | `jane@company.com` | `emp123` |

> **Note:** These accounts are created once on first run and saved locally.
> You will stay logged in between app restarts (session is persisted).
> To reset all data and re-seed, call `StorageService.clearAll()` in code or uninstall the app.

---

## 6. Features

| # | Feature | Description |
|---|---------|-------------|
| 1 | **User Login** | Separate access for Employee, Manager, and Admin roles |
| 2 | **Apply for Leave** | Employees submit leave requests with type, dates, and reason |
| 3 | **Leave Approval** | Managers approve or reject requests with optional notes |
| 4 | **Leave Balance** | Automatically deducted when a request is approved |
| 5 | **Leave Types** | Sick, Casual, Vacation, Maternity, Paternity (configurable) |
| 6 | **Notifications** | In-app alerts for new requests, approvals, and rejections |
| 7 | **Reports** | Admin can filter and view all leave history |
| 8 | **Admin Controls** | Manage employees, roles, and leave policies |

---

## 7. Project Structure

```
lib/
├── main.dart                          # App entry point — sets up providers & routing
│
├── models/                            # Data models (fromJson / toJson)
│   ├── user_model.dart
│   ├── leave_request_model.dart
│   ├── leave_type_model.dart
│   └── notification_model.dart
│
├── services/                          # Business logic layer
│   ├── storage_service.dart           # All JSON read/write via SharedPreferences
│   ├── auth_service.dart              # Login, logout, session persistence
│   ├── leave_service.dart             # Apply, approve, reject, balance deduction
│   ├── notification_service.dart      # Create and read in-app notifications
│   └── user_service.dart              # Admin CRUD for user accounts
│
├── providers/                         # State management (ChangeNotifier)
│   ├── auth_provider.dart
│   ├── leave_provider.dart
│   └── notification_provider.dart
│
├── data/
│   └── initial_data.dart              # Seeds demo users + leave types on first run
│
├── utils/
│   ├── app_colors.dart                # Color palette — edit here to retheme the app
│   ├── app_constants.dart             # Keys, role strings, default values
│   └── date_helper.dart               # Date formatting helpers
│
├── widgets/                           # Reusable UI components
│   ├── leave_card_widget.dart
│   ├── leave_balance_card_widget.dart
│   ├── status_badge_widget.dart
│   ├── custom_button_widget.dart
│   └── custom_text_field_widget.dart
│
└── screens/
    ├── auth/
    │   └── login_screen.dart
    ├── employee/
    │   ├── employee_home_screen.dart  # Bottom nav with dashboard, apply, history, balance
    │   ├── apply_leave_screen.dart
    │   ├── leave_history_screen.dart
    │   └── leave_balance_screen.dart
    ├── manager/
    │   ├── manager_home_screen.dart   # Bottom nav with dashboard, pending, team
    │   ├── pending_requests_screen.dart
    │   └── team_calendar_screen.dart
    ├── admin/
    │   ├── admin_home_screen.dart     # Bottom nav with 5 tabs
    │   ├── manage_employees_screen.dart
    │   ├── leave_policies_screen.dart
    │   └── reports_screen.dart
    └── shared/
        ├── notifications_screen.dart
        └── profile_screen.dart
```

---

## 8. Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.2 | State management (ChangeNotifier) |
| `shared_preferences` | ^2.3.0 | Local JSON storage (no database needed) |
| `intl` | ^0.20.1 | Date and number formatting |
| `uuid` | ^4.5.1 | Generates unique IDs for records |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## 9. Troubleshooting

### `flutter pub get` fails
```bash
# Clear the pub cache and retry
flutter pub cache repair
flutter pub get
```

### App shows a blank screen or crashes on launch
```bash
# Clean the build and rerun
flutter clean
flutter pub get
flutter run
```

### Device not detected
```bash
# Check connected devices
flutter devices

# Check for any setup issues
flutter doctor -v
```

### `Gradle build failed` on Android
1. Open **Android Studio**
2. Go to **File → Invalidate Caches → Invalidate and Restart**
3. Wait for indexing to finish, then run `flutter run` again

Alternatively:
```bash
cd android
./gradlew clean
cd ..
flutter run
```

### Data does not reset between runs
All data is persisted locally. To wipe all data and start fresh, either:
- **Uninstall** the app from the emulator/device, then run again, **or**
- Add a temporary call to `StorageService().clearAll()` inside `main()` before `seedIfEmpty()`, run once, then remove it.

---

## Contributing (Team Members)

1. Pull the latest changes before starting work:
   ```bash
   git pull origin main
   ```
2. Create your own branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. After finishing, push and open a Pull Request:
   ```bash
   git add .
   git commit -m "Add: your feature description"
   git push origin feature/your-feature-name
   ```

---

*Leave Management System — Group 2 | Mobile App Development*
