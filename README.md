# PG DB UI

A cross-platform Flutter application for browsing the Project Gutenberg SQLite database (`pg.db`).

## Features

- Browse books from Project Gutenberg database
- Search books by title, author, or subject
- Filter by author, subject, bookshelf, and language
- View detailed book information
- Navigate to related books via authors and subjects

## Setup

### Installing Flutter

If you don't have Flutter installed, follow these steps:

#### Option 1: Using Git (Recommended)

1. **Install Git** (if not already installed):
   - Download from: https://git-scm.com/download/win
   - Or use: `winget install Git.Git`

2. **Clone Flutter SDK**:
   ```powershell
   cd C:\
   git clone https://github.com/flutter/flutter.git -b stable
   ```

3. **Add Flutter to PATH**:
   - Open "Environment Variables" (search in Windows Start menu)
   - Under "User variables", find and select "Path", then click "Edit"
   - Click "New" and add: `C:\flutter\bin`
   - Click "OK" on all dialogs
   - **Restart your terminal/PowerShell** for changes to take effect

4. **Verify Installation**:
   ```powershell
   flutter doctor
   ```

#### Option 2: Download ZIP

1. **Download Flutter SDK**:
   - Visit: https://docs.flutter.dev/get-started/install/windows
   - Download the latest stable release ZIP file
   - Extract to `C:\flutter` (or your preferred location)

2. **Add Flutter to PATH** (same as Option 1, step 3)

3. **Verify Installation**:
   ```powershell
   flutter doctor
   ```

#### Additional Requirements

Flutter will guide you through installing additional dependencies when you run `flutter doctor`. You may need:

- **Android Studio** (for Android development): https://developer.android.com/studio
- **Visual Studio** (for Windows desktop development): https://visualstudio.microsoft.com/downloads/
  - Install "Desktop development with C++" workload
- **Xcode** (for iOS development, macOS only)

### Running the App

1. **Install Dependencies**:
   ```powershell
   cd C:\code\pg-db-ui
   flutter pub get
   ```

2. **Copy Database File**:
   - Copy `pg.db` from `C:\code\pg-db\pg.db` to the app's documents directory, or
   - The app will automatically look for it in common locations

3. **Run the App**:
   ```powershell
   # For Windows desktop
   flutter run -d windows
   
   # For Android (if device/emulator connected)
   flutter run -d android
   
   # For web
   flutter run -d chrome
   ```

4. **Build for Release**:
   ```powershell
   # Windows
   flutter build windows
   
   # Android
   flutter build apk
   ```

## Database Location

The app will look for `pg.db` in:
- **Android/iOS**: App documents directory
- **Windows/macOS/Linux**: User documents directory or app data directory

You can also select the database file using the file picker when the app starts.

## Building

```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build for specific platform
flutter build windows
flutter build macos
flutter build linux
flutter build apk
flutter build ios
```

