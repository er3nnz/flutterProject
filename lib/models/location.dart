class Location {
  final int? id;
  final String name;
  final String? code;
  final String? notes;

  Location({
    this.id,
    required this.name,
    this.code,
    this.notes,
  });

  Location copyWith({int? id, String? name, String? code, String? notes}) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'notes': notes,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      code: map['code'] as String?,
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() => 'Location{id: $id, name: $name, code: $code}';
}

