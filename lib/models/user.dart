class User {
  final int? id;
  final String username;
  final String role;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.role,
    this.createdAt,
  });

  User copyWith({int? id, String? username, String? role, DateTime? createdAt}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }

  @override
  String toString() => 'User{id: $id, username: $username, role: $role}';
}

