import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Helper class for database file operations
class DatabaseHelper {
  /// Get the default database path
  /// Checks common locations for pg.db file
  static Future<String?> getDatabasePath() async {
    // First, check if pg.db exists in the current directory (for development)
    final currentDir = Directory.current;
    final currentDbPath = path.join(currentDir.path, 'pg.db');
    if (File(currentDbPath).existsSync()) {
      return currentDbPath;
    }

    // Check parent directory (pg-db project)
    final parentDbPath = path.join(currentDir.parent.path, 'pg-db', 'pg.db');
    if (File(parentDbPath).existsSync()) {
      return parentDbPath;
    }

    // Check app documents directory
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final appDbPath = path.join(documentsDir.path, 'pg.db');
      if (File(appDbPath).existsSync()) {
        return appDbPath;
      }
    } catch (e) {
      // Ignore errors on platforms that don't support this
    }

    // Check user's home directory
    try {
      final homeDir = Platform.environment['HOME'] ?? 
                     Platform.environment['USERPROFILE'] ?? '';
      if (homeDir.isNotEmpty) {
        final homeDbPath = path.join(homeDir, 'pg.db');
        if (File(homeDbPath).existsSync()) {
          return homeDbPath;
        }
      }
    } catch (e) {
      // Ignore errors
    }

    return null;
  }

  /// Get the path where database should be stored in app documents
  static Future<String> getAppDatabasePath() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    return path.join(documentsDir.path, 'pg.db');
  }

  /// Copy database file to app documents directory
  static Future<bool> copyDatabaseToApp(String sourcePath) async {
    try {
      final targetPath = await getAppDatabasePath();
      final sourceFile = File(sourcePath);
      final targetFile = File(targetPath);

      // Create directory if it doesn't exist
      await targetFile.parent.create(recursive: true);

      // Copy file
      await sourceFile.copy(targetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if database file exists at path
  static bool databaseExists(String dbPath) {
    return File(dbPath).existsSync();
  }
}

