import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/subject.dart';
import '../models/bookshelf.dart';
import '../models/format.dart';
import '../utils/database_helper.dart';
import 'queries.dart';

/// Database service for managing SQLite database connections and queries
class DatabaseService extends ChangeNotifier {
  Database? _database;
  String? _databasePath;
  bool _isInitialized = false;
  String? _error;

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
        _error = 'Database file not found. Please select pg.db file.';
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
      _error = 'Failed to initialize database: $e';
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  /// Set database path manually
  Future<bool> setDatabasePath(String dbPath) async {
    if (!DatabaseHelper.databaseExists(dbPath)) {
      _error = 'Database file does not exist at: $dbPath';
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

      final books = <Book>[];
      for (final map in maps) {
        final book = Book.fromMap(map);
        // Load related data
        final fullBook = await _loadBookRelations(book);
        books.add(fullBook);
      }

      return books;
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

      final books = <Book>[];
      for (final map in maps) {
        final book = Book.fromMap(map);
        final fullBook = await _loadBookRelations(book);
        books.add(fullBook);
      }

      return books;
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

      final books = <Book>[];
      for (final map in maps) {
        final book = Book.fromMap(map);
        final fullBook = await _loadBookRelations(book);
        books.add(fullBook);
      }

      return books;
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
}

