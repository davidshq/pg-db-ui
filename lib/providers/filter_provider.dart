import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/book.dart';
import '../models/author.dart';
import '../models/subject.dart';
import '../models/bookshelf.dart';
import '../database/database_service.dart';
import '../utils/constants.dart';

/// Provider for managing filter state and filtered book results
class FilterProvider extends ChangeNotifier {
  DatabaseService? _databaseService;
  
  int? _selectedAuthorId;
  int? _selectedSubjectId;
  int? _selectedBookshelfId;
  String? _selectedLanguage;
  
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  int _totalCount = 0;
  Timer? _debounceTimer;

  // Available filter options
  List<Author> _authors = [];
  List<Subject> _subjects = [];
  List<Bookshelf> _bookshelves = [];
  List<String> _languages = [];
  bool _optionsLoaded = false;

  FilterProvider();

  // Getters
  int? get selectedAuthorId => _selectedAuthorId;
  int? get selectedSubjectId => _selectedSubjectId;
  int? get selectedBookshelfId => _selectedBookshelfId;
  String? get selectedLanguage => _selectedLanguage;
  List<Book> get filteredBooks => _filteredBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasMore => _hasMore;
  int get totalCount => _totalCount;
  bool get isEmpty => _filteredBooks.isEmpty && !_isLoading;
  bool get hasActiveFilters => 
    _selectedAuthorId != null || 
    _selectedSubjectId != null || 
    _selectedBookshelfId != null || 
    (_selectedLanguage != null && _selectedLanguage!.isNotEmpty);

  List<Author> get authors => _authors;
  List<Subject> get subjects => _subjects;
  List<Bookshelf> get bookshelves => _bookshelves;
  List<String> get languages => _languages;
  bool get optionsLoaded => _optionsLoaded;

  /// Set database service reference
  void setDatabaseService(DatabaseService databaseService) {
    _databaseService = databaseService;
  }

  /// Load filter options (authors, subjects, bookshelves, languages)
  Future<void> loadFilterOptions() async {
    final db = _databaseService;
    if (db == null || !db.isInitialized) {
      return;
    }

    if (_optionsLoaded) return;

    try {
      // Load authors, subjects, bookshelves, and languages in parallel
      final results = await Future.wait([
        db.getAllAuthors(limit: 1000),
        db.getAllSubjects(limit: 1000),
        db.getAllBookshelves(limit: 1000),
        db.getAllLanguages(),
      ]);

      _authors = results[0] as List<Author>;
      _subjects = results[1] as List<Subject>;
      _bookshelves = results[2] as List<Bookshelf>;
      _languages = results[3] as List<String>;
      
      _optionsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    }
  }

  /// Set author filter
  void setAuthorFilter(int? authorId) {
    _selectedAuthorId = authorId;
    _currentPage = 0;
    _filteredBooks = [];
    _hasMore = true;
    notifyListeners();
    _debouncedApplyFilters();
  }

  /// Set subject filter
  void setSubjectFilter(int? subjectId) {
    _selectedSubjectId = subjectId;
    _currentPage = 0;
    _filteredBooks = [];
    _hasMore = true;
    notifyListeners();
    _debouncedApplyFilters();
  }

  /// Set bookshelf filter
  void setBookshelfFilter(int? bookshelfId) {
    _selectedBookshelfId = bookshelfId;
    _currentPage = 0;
    _filteredBooks = [];
    _hasMore = true;
    notifyListeners();
    _debouncedApplyFilters();
  }

  /// Set language filter
  void setLanguageFilter(String? language) {
    _selectedLanguage = language;
    _currentPage = 0;
    _filteredBooks = [];
    _hasMore = true;
    notifyListeners();
    _debouncedApplyFilters();
  }

  /// Debounced filter application to avoid multiple queries when filters change rapidly
  void _debouncedApplyFilters() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // If no active filters, clear immediately
    if (!hasActiveFilters) {
      _filteredBooks = [];
      _currentPage = 0;
      _hasMore = true;
      _totalCount = 0;
      notifyListeners();
      return;
    }

    // Debounce filter application
    _debounceTimer = Timer(Constants.searchDebounceDuration, () {
      applyFilters();
    });
  }

  /// Apply filters and load filtered books
  Future<void> applyFilters({bool refresh = false}) async {
    final db = _databaseService;
    if (db == null || !db.isInitialized) {
      _error = 'Database not initialized';
      notifyListeners();
      return;
    }

    if (!hasActiveFilters) {
      _filteredBooks = [];
      _currentPage = 0;
      _hasMore = true;
      _totalCount = 0;
      notifyListeners();
      return;
    }

    // Atomic check-and-set to prevent race conditions
    if (_isLoading) return;
    _isLoading = true;

    try {
      _error = null;
      
      if (refresh) {
        _currentPage = 0;
        _filteredBooks = [];
        _hasMore = true;
      }

      notifyListeners();

      final newBooks = await db.getBooksWithFilters(
        authorId: _selectedAuthorId,
        subjectId: _selectedSubjectId,
        bookshelfId: _selectedBookshelfId,
        language: _selectedLanguage,
        limit: Constants.defaultPageSize,
        offset: _currentPage * Constants.defaultPageSize,
      );

      if (refresh) {
        _filteredBooks = newBooks;
      } else {
        _filteredBooks.addAll(newBooks);
      }

      _hasMore = newBooks.length == Constants.defaultPageSize;
      _currentPage++;

      notifyListeners();
    } catch (e) {
      _error = 'Failed to apply filters: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  /// Load more filtered books
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading || !hasActiveFilters) return;
    await applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _debounceTimer?.cancel();
    _selectedAuthorId = null;
    _selectedSubjectId = null;
    _selectedBookshelfId = null;
    _selectedLanguage = null;
    _filteredBooks = [];
    _currentPage = 0;
    _hasMore = true;
    _error = null;
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

