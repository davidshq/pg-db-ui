import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../database/database_service.dart';
import '../utils/constants.dart';

/// Provider for managing book data and state
class BookProvider extends ChangeNotifier {
  final DatabaseService? _databaseService;
  
  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  int _totalCount = 0;

  BookProvider(this._databaseService);

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasMore => _hasMore;
  int get totalCount => _totalCount;
  bool get isEmpty => _books.isEmpty && !_isLoading;

  /// Initialize and load first page of books
  Future<void> initialize() async {
    final db = _databaseService;
    if (db == null || !db.isInitialized) {
      _error = 'Database not initialized';
      notifyListeners();
      return;
    }

    await loadBooks();
  }

  /// Load books (first page or refresh)
  Future<void> loadBooks({bool refresh = false}) async {
    final db = _databaseService;
    if (db == null || !db.isInitialized) {
      _error = 'Database not initialized';
      notifyListeners();
      return;
    }

    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      
      if (refresh) {
        _currentPage = 0;
        _books = [];
        _hasMore = true;
      }

      notifyListeners();

      final newBooks = await db.getBooks(
        limit: Constants.defaultPageSize,
        offset: _currentPage * Constants.defaultPageSize,
      );

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
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load books: $e';
      _isLoading = false;
      notifyListeners();
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
      debugPrint('Error getting book by ID: $e');
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _books = [];
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    _isLoading = false;
    _totalCount = 0;
    notifyListeners();
  }
}

