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
   # For Windows desktop (without waiting for debugger)
   flutter run -d windows --release
   
   # Or run without debugger (faster startup)
   flutter run -d windows --no-debug
   
   # For Android (if device/emulator connected)
   flutter run -d android
   
   # For web
   flutter run -d chrome
   ```
   
   **Note**: By default, `flutter run -d windows` waits for a debugger connection, which can cause it to hang. Use `--release` or `--no-debug` flags to run without waiting for a debugger.

4. **Build for Release**:
   ```powershell
   # Windows
   flutter build windows
   
   # Android
   flutter build apk
   ```

### Windows-Specific Setup

If you encounter issues running the Windows app directly (e.g., after building with `flutter build windows`), you may need to set up the data directory manually:

1. **Build the app**:
   ```powershell
   flutter build windows --debug
   ```

2. **Run the setup script**:
   ```powershell
   .\setup_data_dir.ps1
   ```

   This script will:
   - Check if the executable exists
   - Attempt to create the data directory using Flutter tools
   - Copy the data directory to the correct location
   - Provide clear error messages if something goes wrong

3. **Run the app directly**:
   ```powershell
   .\build\windows\x64\runner\Debug\pg_db_ui.exe
   ```

**Note**: The setup script requires PowerShell and will automatically handle Flutter path detection. If Flutter is not in your PATH, the script will provide helpful warnings.

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

## Troubleshooting

### Windows: App hangs when running with `flutter run`

If `flutter run -d windows` hangs or keeps loading, it's waiting for a debugger connection. Use one of these solutions:

**Option 1: Run without debugger (Recommended)**
```powershell
flutter run -d windows --no-debug
```

**Option 2: Run in release mode**
```powershell
flutter run -d windows --release
```

**Option 3: Build and run directly**
```powershell
# Build first
flutter build windows --debug

# Run the setup script to ensure data directory exists
.\setup_data_dir.ps1

# Run the executable directly
.\build\windows\x64\runner\Debug\pg_db_ui.exe
```

**Option 4: Use Cursor/VS Code debugger (Recommended for debugging)**
1. Make sure you have the **Flutter** and **Dart** extensions installed in Cursor/VS Code
2. Open the project in Cursor
3. Press **F5** or go to **Run and Debug** panel (Ctrl+Shift+D)
4. Select **"Flutter (Windows)"** from the dropdown
5. Click the green play button or press F5

The debugger will automatically connect and you can set breakpoints, inspect variables, and step through code. A `launch.json` configuration file has been created in `.vscode/` with multiple debug configurations.

### Windows: App won't start after building

If the app fails to start after building on Windows, it may be missing the Flutter data directory. Use the setup script:

```powershell
.\setup_data_dir.ps1
```

This script will create and copy the necessary data files to the correct location. Make sure you've built the app first with `flutter build windows --debug`.

### Database file not found

If the app can't find the database file, see the [Database Location](#database-location) section above. You can also use the file picker when the app starts to select the database file manually.

## Development

### Project Structure

```
lib/
├── database/          # Database service and queries
├── models/            # Data models (Book, Author, Subject, etc.)
├── providers/         # State management (BookProvider, SearchProvider, etc.)
├── screens/           # UI screens
├── widgets/           # Reusable widgets
└── utils/             # Utility functions and constants
```

### Running Tests

```powershell
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Formatting

```powershell
# Format code
dart format .

# Analyze code
flutter analyze
```

