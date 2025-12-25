import 'dart:convert';

class AuditLog {
  final int? id;
  final int? userId;
  final String action;
  final String? entity;
  final int? entityId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  AuditLog({
    this.id,
    this.userId,
    required this.action,
    this.entity,
    this.entityId,
    this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'action': action,
      'entity': entity,
      'entity_id': entityId,
      'data': data != null ? jsonEncode(data) : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? parsed;
    if (map['data'] != null) {
      try {
        parsed = Map<String, dynamic>.from(jsonDecode(map['data'] as String));
      } catch (_) {
        parsed = null;
      }
    }
    return AuditLog(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      action: map['action'] as String? ?? '',
      entity: map['entity'] as String?,
      entityId: map['entity_id'] as int?,
      data: parsed,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now() : DateTime.now(),
    );
  }

  @override
  String toString() => 'AuditLog{id: $id, userId: $userId, action: $action, entity: $entity, entityId: $entityId, data: $data, createdAt: $createdAt}';
}
