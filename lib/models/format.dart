/// Format model representing a file format for a book
class Format {
  final int id;
  final int bookId;
  final String formatType;
  final String? fileUrl;
  final int? fileSize;

  Format({
    required this.id,
    required this.bookId,
    required this.formatType,
    this.fileUrl,
    this.fileSize,
  });

  /// Create Format from database map
  factory Format.fromMap(Map<String, dynamic> map) {
    return Format(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      formatType: map['format_type'] as String,
      fileUrl: map['file_url'] as String?,
      fileSize: map['file_size'] as int?,
    );
  }

  /// Convert Format to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'format_type': formatType,
      'file_url': fileUrl,
      'file_size': fileSize,
    };
  }

  /// Get formatted file size (e.g., "1.5 MB")
  String? get formattedFileSize {
    if (fileSize == null) return null;
    if (fileSize! < 1024) return '${fileSize!} B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get format type display name (e.g., "EPUB" instead of "application/epub+zip")
  String get displayType {
    if (formatType.contains('epub')) return 'EPUB';
    if (formatType.contains('pdf')) return 'PDF';
    if (formatType.contains('plain')) return 'Plain Text';
    if (formatType.contains('html')) return 'HTML';
    if (formatType.contains('kindle')) return 'Kindle';
    return formatType.split('/').last.toUpperCase();
  }
}

