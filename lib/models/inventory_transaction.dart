class InventoryTransaction {
  final int? id;
  final int productId;
  final int? locationFromId;
  final int? locationToId;
  final double quantity;
  final String type;
  final String? reference;
  final String? note;
  final int? createdBy;
  final DateTime createdAt;

  InventoryTransaction({
    this.id,
    required this.productId,
    this.locationFromId,
    this.locationToId,
    required this.quantity,
    required this.type,
    this.reference,
    this.note,
    this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  InventoryTransaction copyWith({
    int? id,
    int? productId,
    int? locationFromId,
    int? locationToId,
    double? quantity,
    String? type,
    String? reference,
    String? note,
    int? createdBy,
    DateTime? createdAt,
  }) {
    return InventoryTransaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      locationFromId: locationFromId ?? this.locationFromId,
      locationToId: locationToId ?? this.locationToId,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'location_from_id': locationFromId,
      'location_to_id': locationToId,
      'quantity': quantity,
      'type': type,
      'reference': reference,
      'note': note,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      locationFromId: map['location_from_id'] as int?,
      locationToId: map['location_to_id'] as int?,
      quantity: map['quantity'] != null ? (map['quantity'] as num).toDouble() : 0.0,
      type: map['type'] as String? ?? '',
      reference: map['reference'] as String?,
      note: map['note'] as String?,
      createdBy: map['created_by'] as int?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now() : DateTime.now(),
    );
  }

  @override
  String toString() => 'InventoryTransaction{id: $id, product: $productId, qty: $quantity, type: $type}';
}

