import 'author.dart';
import 'format.dart';

/// Book model representing a book in the database
class Book {
  final int id;
  final String gutenbergId;
  final String? title;
  final String? language;
  final String? publisher;
  final String? license;
  final String? rights;
  final String? issuedDate;
  final int downloadCount;
  final String? description;
  final String? summary;
  final String? productionNotes;
  final String? readingEaseScore;
  final List<Author> authors;
  final List<String> subjects;
  final List<String> bookshelves;
  final List<Format> formats;

  Book({
    required this.id,
    required this.gutenbergId,
    this.title,
    this.language,
    this.publisher,
    this.license,
    this.rights,
    this.issuedDate,
    this.downloadCount = 0,
    this.description,
    this.summary,
    this.productionNotes,
    this.readingEaseScore,
    this.authors = const [],
    this.subjects = const [],
    this.bookshelves = const [],
    this.formats = const [],
  });

  /// Create Book from database map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      gutenbergId: map['gutenberg_id'] as String,
      title: map['title'] as String?,
      language: map['language'] as String?,
      publisher: map['publisher'] as String?,
      license: map['license'] as String?,
      rights: map['rights'] as String?,
      issuedDate: map['issued_date'] as String?,
      downloadCount: map['download_count'] as int? ?? 0,
      description: map['description'] as String?,
      summary: map['summary'] as String?,
      productionNotes: map['production_notes'] as String?,
      readingEaseScore: map['reading_ease_score'] as String?,
    );
  }

  /// Convert Book to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gutenberg_id': gutenbergId,
      'title': title,
      'language': language,
      'publisher': publisher,
      'license': license,
      'rights': rights,
      'issued_date': issuedDate,
      'download_count': downloadCount,
      'description': description,
      'summary': summary,
      'production_notes': productionNotes,
      'reading_ease_score': readingEaseScore,
    };
  }

  /// Get display title (fallback to Gutenberg ID if title is null)
  String get displayTitle => title ?? 'Untitled (${gutenbergId})';

  /// Get authors display string
  String get authorsDisplay {
    if (authors.isEmpty) return 'Unknown Author';
    return authors.map((a) => a.displayName).join(', ');
  }

  /// Get formatted download count
  String get formattedDownloadCount {
    if (downloadCount < 1000) return downloadCount.toString();
    if (downloadCount < 1000000) {
      return '${(downloadCount / 1000).toStringAsFixed(1)}K';
    }
    return '${(downloadCount / 1000000).toStringAsFixed(1)}M';
  }
}

