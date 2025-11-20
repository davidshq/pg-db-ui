import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../database/database_service.dart';
import '../utils/constants.dart';
import '../utils/error_messages.dart';

/// Provider for managing book data and state
class BookProvider extends ChangeNotifier {
  DatabaseService? _databaseService;
  
  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  int _totalCount = 0;
  bool _disposed = false;

  BookProvider(this._databaseService);
  
  /// Set database service reference (allows updating after creation)
  void setDatabaseService(DatabaseService databaseService) {
    // Only reset if this is a new database service instance
    final isNewService = _databaseService != databaseService;
    _databaseService = databaseService;
    
    // Reset state when database service is set to ensure clean initialization
    if (isNewService) {
      _books = [];
      _currentPage = 0;
      _hasMore = true;
      _error = null;
      _isLoading = false;
      _totalCount = 0;
      debugPrint('BookProvider: Database service set, state reset');
      _safeNotifyListeners();
    }
  }
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
  /// Safely notify listeners only if not disposed
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasMore => _hasMore;
  int get totalCount => _totalCount;
  bool get isEmpty => _books.isEmpty && !_isLoading;

  /// Initialize and load first page of books
  Future<void> initialize() async {
    debugPrint('BookProvider: initialize() called');
    final db = _databaseService;
    if (db == null || !db.isInitialized) {
      debugPrint('BookProvider: Database not initialized (db: ${db != null}, initialized: ${db?.isInitialized})');
      _error = ErrorMessages.databaseNotInitialized;
      _safeNotifyListeners();
      return;
    }

    debugPrint('BookProvider: Starting to load books...');
    // Always refresh on initialization to ensure we start with a clean state
    await loadBooks(refresh: true);
    debugPrint('BookProvider: initialize() completed, books count: ${_books.length}');
  }

  /// Load books (first page or refresh)
  Future<void> loadBooks({bool refresh = false}) async {
    debugPrint('BookProvider: loadBooks() called (refresh: $refresh, isLoading: $_isLoading)');
    final db = _databaseService;
    if (db == null || !db.isInitialized) {
      debugPrint('BookProvider: Database not initialized in loadBooks (db: ${db != null}, initialized: ${db?.isInitialized})');
      _error = ErrorMessages.databaseNotInitialized;
      _safeNotifyListeners();
      return;
    }

    // Atomic check-and-set to prevent race conditions
    if (_isLoading) {
      debugPrint('BookProvider: Already loading, skipping...');
      return;
    }
    _isLoading = true;
    debugPrint('BookProvider: Starting database query...');

    try {
      _error = null;
      
      if (refresh) {
        _currentPage = 0;
        _books = [];
        _hasMore = true;
      }

      _safeNotifyListeners();

      final newBooks = await db.getBooks(
        limit: Constants.defaultPageSize,
        offset: _currentPage * Constants.defaultPageSize,
      );

      // Check if disposed after async operation
      if (_disposed) {
        debugPrint('BookProvider: Provider was disposed during async operation, aborting...');
        return;
      }

      debugPrint('BookProvider: Loaded ${newBooks.length} books (refresh: $refresh, page: $_currentPage)');

      if (refresh) {
        _books = newBooks;
      } else {
        _books.addAll(newBooks);
      }

      _hasMore = newBooks.length == Constants.defaultPageSize;
      _currentPage++;
      
      // Get total count if first load
      if (_currentPage == 1) {
        _totalCount = await db.countBooks();
        debugPrint('BookProvider: Total books in database: $_totalCount');
        // Check again after async operation
        if (_disposed) return;
      }

      debugPrint('BookProvider: Total books loaded: ${_books.length}');
      _safeNotifyListeners();
    } catch (e, stackTrace) {
      // Check if disposed before updating state
      if (_disposed) return;
      
      _error = ErrorMessages.failedToLoadBooks;
      debugPrint('BookProvider: Error loading books: $e');
      debugPrint('BookProvider: Stack trace: $stackTrace');
      debugPrint(ErrorMessages.forLogging(ErrorMessages.failedToLoadBooks, e));
      _safeNotifyListeners();
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  /// Load more books (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await loadBooks();
  }

  /// Refresh books list
  Future<void> refresh() async {
    await loadBooks(refresh: true);
  }

  /// Get book by ID
  Future<Book?> getBookById(int id) async {
    final db = _databaseService;
    if (db == null || !db.isInitialized) {
      return null;
    }

    try {
      return await db.getBookById(id);
    } catch (e) {
      debugPrint(ErrorMessages.forLogging(ErrorMessages.failedToGetBook, e));
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  /// Reset provider state
  void reset() {
    _books = [];
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    _isLoading = false;
    _totalCount = 0;
    _safeNotifyListeners();
  }
}

