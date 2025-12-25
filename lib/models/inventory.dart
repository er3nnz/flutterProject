class Inventory {
  final int? id;
  final int productId;
  final int locationId;
  final double quantity;
  final double reservedQuantity;
  final DateTime? lastCountedAt;

  Inventory({
    this.id,
    required this.productId,
    required this.locationId,
    required this.quantity,
    this.reservedQuantity = 0,
    this.lastCountedAt,
  });

  Inventory copyWith({
    int? id,
    int? productId,
    int? locationId,
    double? quantity,
    double? reservedQuantity,
    DateTime? lastCountedAt,
  }) {
    return Inventory(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      locationId: locationId ?? this.locationId,
      quantity: quantity ?? this.quantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      lastCountedAt: lastCountedAt ?? this.lastCountedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'location_id': locationId,
      'quantity': quantity,
      'reserved_quantity': reservedQuantity,
      'last_counted_at': lastCountedAt?.toIso8601String(),
    };
  }

  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'] as int?,
      productId: map['product_id'] is int ? map['product_id'] as int : int.parse(map['product_id'].toString()),
      locationId: map['location_id'] is int ? map['location_id'] as int : int.parse(map['location_id'].toString()),
      quantity: map['quantity'] != null ? (map['quantity'] as num).toDouble() : 0.0,
      reservedQuantity: map['reserved_quantity'] != null ? (map['reserved_quantity'] as num).toDouble() : 0.0,
      lastCountedAt: map['last_counted_at'] != null ? DateTime.tryParse(map['last_counted_at'] as String) : null,
    );
  }

  @override
  String toString() => 'Inventory{id: $id, product: $productId, location: $locationId, qty: $quantity}';
}
