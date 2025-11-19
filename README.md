# PG DB UI

A cross-platform Flutter application for browsing the Project Gutenberg SQLite database (`pg.db`).

## Features

- Browse books from Project Gutenberg database
- Search books by title, author, or subject
- Filter by author, subject, bookshelf, and language
- View detailed book information
- Navigate to related books via authors and subjects

## Setup

1. Ensure you have Flutter installed (SDK >=3.0.0)
2. Copy `pg.db` from the `pg-db` project to this app's documents directory, or use the file picker in the app
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

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

