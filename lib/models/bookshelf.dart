/// Bookshelf model representing a bookshelf/category classification
class Bookshelf {
  final int id;
  final String bookshelf;

  Bookshelf({
    required this.id,
    required this.bookshelf,
  });

  /// Create Bookshelf from database map
  factory Bookshelf.fromMap(Map<String, dynamic> map) {
    return Bookshelf(
      id: map['id'] as int,
      bookshelf: map['bookshelf'] as String,
    );
  }

  /// Convert Bookshelf to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookshelf': bookshelf,
    };
  }
}

