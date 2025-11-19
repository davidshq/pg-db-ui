/// Centralized error messages for consistent error handling across the application
class ErrorMessages {
  // Database errors
  static const String databaseNotInitialized = 'Database not initialized';
  static const String databaseFileNotFound = 'Database file not found. Please select the database file.';
  static const String databaseFileDoesNotExist = 'Database file does not exist at the specified location.';
  static const String databaseInitializationFailed = 'Failed to initialize database';
  
  // Database dialog messages
  static const String databaseNotFoundTitle = 'Database Not Found';
  static const String databaseNotFoundContent = 
      'The database file was not found. Please ensure the database file exists in the expected location or select it manually.';

  // Book errors
  static const String bookNotFound = 'Book not found';
  static const String failedToLoadBooks = 'Failed to load books';
  static const String failedToLoadBook = 'Failed to load book';
  static const String failedToGetBook = 'Failed to retrieve book';

  // Search errors
  static const String searchFailed = 'Search failed';
  static const String searchError = 'An error occurred while searching';

  // Filter errors
  static const String failedToApplyFilters = 'Failed to apply filters';
  static const String filterError = 'An error occurred while applying filters';

  // Generic errors
  static const String operationFailed = 'Operation failed';
  static const String unexpectedError = 'An unexpected error occurred';

  /// Format error message with optional details
  /// 
  /// [baseMessage] - The base error message
  /// [details] - Optional additional details (e.g., exception message)
  /// [includeDetails] - Whether to include details in user-facing message (default: false)
  static String format(String baseMessage, {Object? details, bool includeDetails = false}) {
    if (details != null && includeDetails) {
      return '$baseMessage: $details';
    }
    return baseMessage;
  }

  /// Format error message for user display (without technical details)
  static String userFriendly(String baseMessage) {
    return baseMessage;
  }

  /// Format error message for logging (with technical details)
  static String forLogging(String baseMessage, Object? details) {
    if (details != null) {
      return '$baseMessage: $details';
    }
    return baseMessage;
  }
}

