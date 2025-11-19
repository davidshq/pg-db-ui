/// Author model representing an author in the database
class Author {
  final int id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? agentId;
  final String? alias;
  final String? webpage;
  final int? birthYear;
  final int? deathYear;

  Author({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    this.agentId,
    this.alias,
    this.webpage,
    this.birthYear,
    this.deathYear,
  });

  /// Create Author from database map
  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      id: map['id'] as int,
      name: map['name'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      agentId: map['agent_id'] as String?,
      alias: map['alias'] as String?,
      webpage: map['webpage'] as String?,
      birthYear: map['birth_year'] as int?,
      deathYear: map['death_year'] as int?,
    );
  }

  /// Convert Author to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'agent_id': agentId,
      'alias': alias,
      'webpage': webpage,
      'birth_year': birthYear,
      'death_year': deathYear,
    };
  }

  /// Get display name (full name or name)
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return name;
  }

  /// Get lifespan string (e.g., "1800-1900")
  String? get lifespan {
    if (birthYear != null || deathYear != null) {
      final birth = birthYear?.toString() ?? '?';
      final death = deathYear?.toString() ?? '?';
      return '$birth-$death';
    }
    return null;
  }
}

