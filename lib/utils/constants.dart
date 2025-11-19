/// Application constants
class Constants {
  // Database
  static const String databaseFileName = 'pg.db';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Search
  static const int minSearchLength = 2;
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);
  
  // UI
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 8.0;
  static const double listItemHeight = 100.0;
}

