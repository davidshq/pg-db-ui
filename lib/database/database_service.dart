import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/subject.dart';
import '../models/bookshelf.dart';
import '../models/format.dart';
import '../utils/database_helper.dart';
import '../utils/error_messages.dart';
import 'queries.dart';

/// Database service for managing SQLite database connections and queries
class DatabaseService extends ChangeNotifier {
  Database? _database;
  String? _databasePath;
  bool _isInitialized = false;
  String? _error;
  static bool _ffiInitialized = false;

  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Initialize database connection
  Future<bool> initialize({String? dbPath}) async {
    try {
      _error = null;
      
      // Use provided path or try to find database
      if (dbPath != null) {
        _databasePath = dbPath;
      } else {
        _databasePath = await DatabaseHelper.getDatabasePath();
      }

      if (_databasePath == null || !DatabaseHelper.databaseExists(_databasePath!)) {
        _error = ErrorMessages.databaseFileNotFound;
        notifyListeners();
        return false;
      }

      // Open database
      _database = await openDatabase(
        _databasePath!,
        readOnly: true,
        singleInstance: true,
      );

      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMessages.format(ErrorMessages.databaseInitializationFailed, details: e, includeDetails: false);
      debugPrint(ErrorMessages.forLogging(ErrorMessages.databaseInitializationFailed, e));
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  /// Set database path manually
  Future<bool> setDatabasePath(String dbPath) async {
    if (!DatabaseHelper.databaseExists(dbPath)) {
      _error = ErrorMessages.databaseFileDoesNotExist;
      notifyListeners();
      return false;
    }

    // Close existing connection if any
    await close();

    return await initialize(dbPath: dbPath);
  }

  /// Close database connection
  Future<void> close() async {
    await _database?.close();
    _database = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Get books with pagination
  Future<List<Book>> getBooks({
    int limit = 20,
    int offset = 0,
    String? sortBy,
  }) async {
    if (_database == null) return [];

    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        Queries.getBooks,
        [limit, offset],
      );

      final books = maps.map((map) => Book.fromMap(map)).toList();
      
      // Batch load all relations at once (optimized to avoid N+1 queries)
      return await _loadBooksRelations(books);
    } catch (e) {
      debugPrint('Error getting books: $e');
      return [];
    }
  }

  /// Search books
  Future<List<Book>> searchBooks({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    if (_database == null) return [];

    try {
      final searchPattern = '%$query%';
      final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        Queries.searchBooks,
        [searchPattern, searchPattern, searchPattern, searchPattern, limit, offset],
      );

      final books = maps.map((map) => Book.fromMap(map)).toList();
      
      // Batch load all relations at once (optimized to avoid N+1 queries)
      return await _loadBooksRelations(books);
    } catch (e) {
      debugPrint('Error searching books: $e');
      return [];
    }
  }

  /// Get books with filters
  Future<List<Book>> getBooksWithFilters({
    int? authorId,
    int? subjectId,
    int? bookshelfId,
    String? language,
    int limit = 20,
    int offset = 0,
  }) async {
    if (_database == null) return [];

    try {
      final conditions = <String>[];
      final args = <dynamic>[];

      if (authorId != null) {
        conditions.add('ba.author_id = ?');
        args.add(authorId);
      }
      if (subjectId != null) {
        conditions.add('bs.subject_id = ?');
        args.add(subjectId);
      }
      if (bookshelfId != null) {
        conditions.add('bbs.bookshelf_id = ?');
        args.add(bookshelfId);
      }
      if (language != null && language.isNotEmpty) {
        conditions.add('b.language = ?');
        args.add(language);
      }

      String query = Queries.getBooksWithFilters;
      if (conditions.isNotEmpty) {
        query += ' AND ${conditions.join(' AND ')}';
      }
      query += ' ORDER BY b.download_count DESC, b.title ASC LIMIT ? OFFSET ?';
      args.addAll([limit, offset]);

      final List<Map<String, dynamic>> maps = await _database!.rawQuery(query, args);

      final books = maps.map((map) => Book.fromMap(map)).toList();
      
      // Batch load all relations at once (optimized to avoid N+1 queries)
      return await _loadBooksRelations(books);
    } catch (e) {
      debugPrint('Error getting filtered books: $e');
      return [];
    }
  }

  /// Get book by ID
  Future<Book?> getBookById(int id) async {
    if (_database == null) return null;

    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        Queries.getBookById,
        [id],
      );

      if (maps.isEmpty) return null;

      final book = Book.fromMap(maps.first);
      return await _loadBookRelations(book);
    } catch (e) {
      debugPrint('Error getting book by ID: $e');
      return null;
    }
  }

  /// Get book by Gutenberg ID
  Future<Book?> getBookByGutenbergId(String gutenbergId) async {
    if (_database == null) return null;

    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        Queries.getBookByGutenbergId,
        [gutenbergId],
      );

      if (maps.isEmpty) return null;

      final book = Book.fromMap(maps.first);
      return await _loadBookRelations(book);
    } catch (e) {
      debugPrint('Error getting book by Gutenberg ID: $e');
      return null;
    }
  }

  /// Load related data for a book (authors, subjects, bookshelves, formats)
  Future<Book> _loadBookRelations(Book book) async {
    if (_database == null) return book;

    try {
      // Load authors
      final authorMaps = await _database!.rawQuery(
        Queries.getAuthorsForBook,
        [book.id],
      );
      final authors = authorMaps.map((map) => Author.fromMap(map)).toList();

      // Load subjects
      final subjectMaps = await _database!.rawQuery(
        Queries.getSubjectsForBook,
        [book.id],
      );
      final subjects = subjectMaps.map((map) => Subject.fromMap(map).subject).toList();

      // Load bookshelves
      final bookshelfMaps = await _database!.rawQuery(
        Queries.getBookshelvesForBook,
        [book.id],
      );
      final bookshelves = bookshelfMaps.map((map) => Bookshelf.fromMap(map).bookshelf).toList();

      // Load formats
      final formatMaps = await _database!.rawQuery(
        Queries.getFormatsForBook,
        [book.id],
      );
      final formats = formatMaps.map((map) => Format.fromMap(map)).toList();

      return Book(
        id: book.id,
        gutenbergId: book.gutenbergId,
        title: book.title,
        language: book.language,
        publisher: book.publisher,
        license: book.license,
        rights: book.rights,
        issuedDate: book.issuedDate,
        downloadCount: book.downloadCount,
        description: book.description,
        summary: book.summary,
        productionNotes: book.productionNotes,
        readingEaseScore: book.readingEaseScore,
        authors: authors,
        subjects: subjects,
        bookshelves: bookshelves,
        formats: formats,
      );
    } catch (e) {
      debugPrint('Error loading book relations: $e');
      return book;
    }
  }

  /// Batch load related data for multiple books (optimized to avoid N+1 queries)
  Future<List<Book>> _loadBooksRelations(List<Book> books) async {
    if (_database == null || books.isEmpty) return books;

    try {
      final bookIds = books.map((b) => b.id).toList();
      if (bookIds.isEmpty) return books;

      // Load all relations in parallel using batch queries
      final results = await Future.wait([
        _database!.rawQuery(Queries.getAuthorsForBooks(bookIds), bookIds),
        _database!.rawQuery(Queries.getSubjectsForBooks(bookIds), bookIds),
        _database!.rawQuery(Queries.getBookshelvesForBooks(bookIds), bookIds),
        _database!.rawQuery(Queries.getFormatsForBooks(bookIds), bookIds),
      ]);

      final authorMaps = results[0] as List<Map<String, dynamic>>;
      final subjectMaps = results[1] as List<Map<String, dynamic>>;
      final bookshelfMaps = results[2] as List<Map<String, dynamic>>;
      final formatMaps = results[3] as List<Map<String, dynamic>>;

      // Group relations by book_id
      final authorsByBookId = <int, List<Author>>{};
      for (final map in authorMaps) {
        final bookId = map['book_id'] as int;
        authorsByBookId.putIfAbsent(bookId, () => []).add(Author.fromMap(map));
      }

      final subjectsByBookId = <int, List<String>>{};
      for (final map in subjectMaps) {
        final bookId = map['book_id'] as int;
        subjectsByBookId.putIfAbsent(bookId, () => []).add(Subject.fromMap(map).subject);
      }

      final bookshelvesByBookId = <int, List<String>>{};
      for (final map in bookshelfMaps) {
        final bookId = map['book_id'] as int;
        bookshelvesByBookId.putIfAbsent(bookId, () => []).add(Bookshelf.fromMap(map).bookshelf);
      }

      final formatsByBookId = <int, List<Format>>{};
      for (final map in formatMaps) {
        final bookId = map['book_id'] as int;
        formatsByBookId.putIfAbsent(bookId, () => []).add(Format.fromMap(map));
      }

      // Create books with relations
      return books.map((book) {
        return Book(
          id: book.id,
          gutenbergId: book.gutenbergId,
          title: book.title,
          language: book.language,
          publisher: book.publisher,
          license: book.license,
          rights: book.rights,
          issuedDate: book.issuedDate,
          downloadCount: book.downloadCount,
          description: book.description,
          summary: book.summary,
          productionNotes: book.productionNotes,
          readingEaseScore: book.readingEaseScore,
          authors: authorsByBookId[book.id] ?? [],
          subjects: subjectsByBookId[book.id] ?? [],
          bookshelves: bookshelvesByBookId[book.id] ?? [],
          formats: formatsByBookId[book.id] ?? [],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error batch loading book relations: $e');
      return books;
    }
  }

  /// Get all authors
  Future<List<Author>> getAllAuthors({int limit = 100, int offset = 0}) async {
    if (_database == null) return [];

    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        Queries.getAllAuthors,
        [limit, offset],
      );

      return maps.map((map) => Author.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting authors: $e');
      return [];
    }
  }

  /// Get all subjects
  Future<List<Subject>> getAllSubjects({int limit = 100, int offset = 0}) async {
    if (_database == null) return [];

    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        Queries.getAllSubjects,
        [limit, offset],
      );

      return maps.map((map) => Subject.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting subjects: $e');
      return [];
    }
  }

  /// Get all bookshelves
  Future<List<Bookshelf>> getAllBookshelves({int limit = 100, int offset = 0}) async {
    if (_database == null) return [];

    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        Queries.getAllBookshelves,
        [limit, offset],
      );

      return maps.map((map) => Bookshelf.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting bookshelves: $e');
      return [];
    }
  }

  /// Count total books
  Future<int> countBooks() async {
    if (_database == null) return 0;

    try {
      final result = await _database!.rawQuery(Queries.countBooks);
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error counting books: $e');
      return 0;
    }
  }

  /// Count search results
  Future<int> countSearchResults(String query) async {
    if (_database == null) return 0;

    try {
      final searchPattern = '%$query%';
      final result = await _database!.rawQuery(
        Queries.countSearchResults,
        [searchPattern, searchPattern, searchPattern, searchPattern],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error counting search results: $e');
      return 0;
    }
  }

  /// Get all distinct languages from books
  Future<List<String>> getAllLanguages() async {
    if (_database == null) return [];

    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        Queries.getAllLanguages,
      );

      return maps
          .map((map) => map['language'] as String?)
          .where((lang) => lang != null && lang.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }
}

