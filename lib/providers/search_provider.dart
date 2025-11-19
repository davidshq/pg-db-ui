import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/book.dart';
import '../database/database_service.dart';
import '../utils/constants.dart';

/// Provider for managing search state and results
class SearchProvider extends ChangeNotifier {
  DatabaseService? _databaseService;
  
  String _query = '';
  List<Book> _results = [];
  bool _isSearching = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  int _totalCount = 0;
  Timer? _debounceTimer;

  SearchProvider();

  String get query => _query;
  List<Book> get results => _results;
  bool get isSearching => _isSearching;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasMore => _hasMore;
  int get totalCount => _totalCount;
  bool get isEmpty => _results.isEmpty && !_isSearching;
  bool get hasQuery => _query.isNotEmpty;

  /// Set database service reference
  void setDatabaseService(DatabaseService databaseService) {
    _databaseService = databaseService;
  }

  /// Update search query with debouncing
  void updateQuery(String newQuery) {
    _query = newQuery;
    notifyListeners();

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear results if query is too short
    if (newQuery.length < Constants.minSearchLength) {
      _results = [];
      _currentPage = 0;
      _hasMore = true;
      _totalCount = 0;
      notifyListeners();
      return;
    }

    // Debounce search
    _debounceTimer = Timer(Constants.searchDebounceDuration, () {
      search(newQuery);
    });
  }

  /// Perform search
  Future<void> search(String query, {bool refresh = false}) async {
    final db = _databaseService;
    if (db == null || !db.isInitialized) {
      _error = 'Database not initialized';
      notifyListeners();
      return;
    }

    if (query.length < Constants.minSearchLength) {
      _results = [];
      _currentPage = 0;
      _hasMore = true;
      _totalCount = 0;
      notifyListeners();
      return;
    }

    if (_isSearching) return;

    try {
      _isSearching = true;
      _error = null;
      
      if (refresh) {
        _currentPage = 0;
        _results = [];
        _hasMore = true;
      }

      notifyListeners();

      final newResults = await db.searchBooks(
        query: query,
        limit: Constants.defaultPageSize,
        offset: _currentPage * Constants.defaultPageSize,
      );

      if (refresh) {
        _results = newResults;
      } else {
        _results.addAll(newResults);
      }

      _hasMore = newResults.length == Constants.defaultPageSize;
      _currentPage++;
      
      // Get total count if first search
      if (_currentPage == 1) {
        _totalCount = await db.countSearchResults(query);
      }

      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _error = 'Search failed: $e';
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Load more search results
  Future<void> loadMore() async {
    if (!_hasMore || _isSearching || _query.isEmpty) return;
    await search(_query);
  }

  /// Clear search
  void clear() {
    _debounceTimer?.cancel();
    _query = '';
    _results = [];
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    _isSearching = false;
    _totalCount = 0;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

