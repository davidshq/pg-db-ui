/// SQL query constants for database operations
class Queries {
  // Books
  static const String getBooks = '''
    SELECT 
      b.id, b.gutenberg_id, b.title, b.language, b.publisher, 
      b.license, b.rights, b.issued_date, b.download_count,
      b.description, b.summary, b.production_notes, b.reading_ease_score
    FROM books b
    ORDER BY b.download_count DESC, b.title ASC
    LIMIT ? OFFSET ?
  ''';

  static const String getBooksWithFilters = '''
    SELECT DISTINCT
      b.id, b.gutenberg_id, b.title, b.language, b.publisher, 
      b.license, b.rights, b.issued_date, b.download_count,
      b.description, b.summary, b.production_notes, b.reading_ease_score
    FROM books b
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    LEFT JOIN book_subjects bs ON b.id = bs.book_id
    LEFT JOIN subjects s ON bs.subject_id = s.id
    LEFT JOIN book_bookshelves bbs ON b.id = bbs.book_id
    LEFT JOIN bookshelves bsh ON bbs.bookshelf_id = bsh.id
    WHERE 1=1
  ''';

  static const String searchBooks = '''
    SELECT DISTINCT
      b.id, b.gutenberg_id, b.title, b.language, b.publisher, 
      b.license, b.rights, b.issued_date, b.download_count,
      b.description, b.summary, b.production_notes, b.reading_ease_score
    FROM books b
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    LEFT JOIN book_subjects bs ON b.id = bs.book_id
    LEFT JOIN subjects s ON bs.subject_id = s.id
    WHERE 
      b.title LIKE ? OR
      b.description LIKE ? OR
      a.name LIKE ? OR
      s.subject LIKE ?
    ORDER BY b.download_count DESC, b.title ASC
    LIMIT ? OFFSET ?
  ''';

  static const String getBookById = '''
    SELECT 
      b.id, b.gutenberg_id, b.title, b.language, b.publisher, 
      b.license, b.rights, b.issued_date, b.download_count,
      b.description, b.summary, b.production_notes, b.reading_ease_score
    FROM books b
    WHERE b.id = ?
  ''';

  static const String getBookByGutenbergId = '''
    SELECT 
      b.id, b.gutenberg_id, b.title, b.language, b.publisher, 
      b.license, b.rights, b.issued_date, b.download_count,
      b.description, b.summary, b.production_notes, b.reading_ease_score
    FROM books b
    WHERE b.gutenberg_id = ?
  ''';

  // Authors
  static const String getAuthorsForBook = '''
    SELECT a.id, a.name, a.first_name, a.last_name, a.agent_id, 
           a.alias, a.webpage, a.birth_year, a.death_year
    FROM authors a
    INNER JOIN book_authors ba ON a.id = ba.author_id
    WHERE ba.book_id = ?
    ORDER BY a.name
  ''';

  static const String getAllAuthors = '''
    SELECT id, name, first_name, last_name, agent_id, 
           alias, webpage, birth_year, death_year
    FROM authors
    ORDER BY name
    LIMIT ? OFFSET ?
  ''';

  static const String searchAuthors = '''
    SELECT id, name, first_name, last_name, agent_id, 
           alias, webpage, birth_year, death_year
    FROM authors
    WHERE name LIKE ? OR first_name LIKE ? OR last_name LIKE ?
    ORDER BY name
    LIMIT ? OFFSET ?
  ''';

  // Subjects
  static const String getSubjectsForBook = '''
    SELECT s.id, s.subject
    FROM subjects s
    INNER JOIN book_subjects bs ON s.id = bs.subject_id
    WHERE bs.book_id = ?
    ORDER BY s.subject
  ''';

  static const String getAllSubjects = '''
    SELECT id, subject
    FROM subjects
    ORDER BY subject
    LIMIT ? OFFSET ?
  ''';

  // Bookshelves
  static const String getBookshelvesForBook = '''
    SELECT bsh.id, bsh.bookshelf
    FROM bookshelves bsh
    INNER JOIN book_bookshelves bbs ON bsh.id = bbs.bookshelf_id
    WHERE bbs.book_id = ?
    ORDER BY bsh.bookshelf
  ''';

  static const String getAllBookshelves = '''
    SELECT id, bookshelf
    FROM bookshelves
    ORDER BY bookshelf
    LIMIT ? OFFSET ?
  ''';

  // Formats
  static const String getFormatsForBook = '''
    SELECT id, book_id, format_type, file_url, file_size
    FROM formats
    WHERE book_id = ?
    ORDER BY format_type
  ''';

  // Batch loading queries for multiple books
  static String getAuthorsForBooks(List<int> bookIds) {
    final placeholders = bookIds.map((_) => '?').join(',');
    return '''
      SELECT a.id, a.name, a.first_name, a.last_name, a.agent_id, 
             a.alias, a.webpage, a.birth_year, a.death_year, ba.book_id
      FROM authors a
      INNER JOIN book_authors ba ON a.id = ba.author_id
      WHERE ba.book_id IN ($placeholders)
      ORDER BY ba.book_id, a.name
    ''';
  }

  static String getSubjectsForBooks(List<int> bookIds) {
    final placeholders = bookIds.map((_) => '?').join(',');
    return '''
      SELECT s.id, s.subject, bs.book_id
      FROM subjects s
      INNER JOIN book_subjects bs ON s.id = bs.subject_id
      WHERE bs.book_id IN ($placeholders)
      ORDER BY bs.book_id, s.subject
    ''';
  }

  static String getBookshelvesForBooks(List<int> bookIds) {
    final placeholders = bookIds.map((_) => '?').join(',');
    return '''
      SELECT bsh.id, bsh.bookshelf, bbs.book_id
      FROM bookshelves bsh
      INNER JOIN book_bookshelves bbs ON bsh.id = bbs.bookshelf_id
      WHERE bbs.book_id IN ($placeholders)
      ORDER BY bbs.book_id, bsh.bookshelf
    ''';
  }

  static String getFormatsForBooks(List<int> bookIds) {
    final placeholders = bookIds.map((_) => '?').join(',');
    return '''
      SELECT id, book_id, format_type, file_url, file_size
      FROM formats
      WHERE book_id IN ($placeholders)
      ORDER BY book_id, format_type
    ''';
  }

  // Count queries
  static const String countBooks = 'SELECT COUNT(*) FROM books';
  
  static const String countBooksWithFilters = '''
    SELECT COUNT(DISTINCT b.id)
    FROM books b
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    LEFT JOIN book_subjects bs ON b.id = bs.book_id
    LEFT JOIN subjects s ON bs.subject_id = s.id
    LEFT JOIN book_bookshelves bbs ON b.id = bbs.book_id
    LEFT JOIN bookshelves bsh ON bbs.bookshelf_id = bsh.id
    WHERE 1=1
  ''';

  static const String countSearchResults = '''
    SELECT COUNT(DISTINCT b.id)
    FROM books b
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    LEFT JOIN book_subjects bs ON b.id = bs.book_id
    LEFT JOIN subjects s ON bs.subject_id = s.id
    WHERE 
      b.title LIKE ? OR
      b.description LIKE ? OR
      a.name LIKE ? OR
      s.subject LIKE ?
  ''';

  // Languages
  static const String getAllLanguages = '''
    SELECT DISTINCT language
    FROM books
    WHERE language IS NOT NULL AND language != ''
    ORDER BY language
  ''';
}

