/// Subject model representing a subject/topic category
class Subject {
  final int id;
  final String subject;

  Subject({
    required this.id,
    required this.subject,
  });

  /// Create Subject from database map
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as int,
      subject: map['subject'] as String,
    );
  }

  /// Convert Subject to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
    };
  }
}

