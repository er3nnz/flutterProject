class Product {
  final int? id;
  final String? sku;
  final String name;
  final String? description;
  final String unit;
  final String? barcode;
  final int reorderLevel;
  final double? costPrice;
  final double? salePrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    this.sku,
    required this.name,
    this.description,
    required this.unit,
    this.barcode,
    this.reorderLevel = 0,
    this.costPrice,
    this.salePrice,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    int? id,
    String? sku,
    String? name,
    String? description,
    String? unit,
    String? barcode,
    int? reorderLevel,
    double? costPrice,
    double? salePrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'unit': unit,
      'barcode': barcode,
      'reorder_level': reorderLevel,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      sku: map['sku'] as String?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      unit: map['unit'] as String? ?? '',
      barcode: map['barcode'] as String?,
      reorderLevel: map['reorder_level'] is int ? map['reorder_level'] as int : (map['reorder_level'] != null ? int.tryParse(map['reorder_level'].toString()) ?? 0 : 0),
      costPrice: map['cost_price'] != null ? (map['cost_price'] as num).toDouble() : null,
      salePrice: map['sale_price'] != null ? (map['sale_price'] as num).toDouble() : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, sku: $sku, name: $name, unit: $unit, barcode: $barcode}';
  }
}

