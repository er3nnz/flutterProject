import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/inventory_transaction.dart';
import '../models/product.dart';
import '../models/location.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<InventoryTransaction> _transactions = [];
  Map<int, Product> _products = {};
  Map<int, Location> _locations = {};
  bool _isLoading = true;
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final transactionsData = await DatabaseHelper.instance.getInventoryTransactions(
        productId: _selectedProductId,
      );
      final productsData = await DatabaseHelper.instance.getProducts();
      final locationsData = await DatabaseHelper.instance.getLocations();

      final products = productsData.map((p) => Product.fromMap(p)).toList();
      final locations = locationsData.map((l) => Location.fromMap(l)).toList();

      final productMap = <int, Product>{};
      for (var product in products) {
        if (product.id != null) {
          productMap[product.id!] = product;
        }
      }

      final locationMap = <int, Location>{};
      for (var location in locations) {
        if (location.id != null) {
          locationMap[location.id!] = location;
        }
      }

      setState(() {
        _transactions = transactionsData.map((t) => InventoryTransaction.fromMap(t)).toList();
        _products = productMap;
        _locations = locationMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getTransactionTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'in':
        return 'Giriş';
      case 'out':
        return 'Çıkış';
      case 'transfer':
        return 'Transfer';
      case 'adjustment':
        return 'Düzeltme';
      default:
        return type;
    }
  }

  Color _getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'in':
        return Colors.green;
      case 'out':
        return Colors.red;
      case 'transfer':
        return Colors.blue;
      case 'adjustment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'in':
        return Icons.arrow_downward_rounded;
      case 'out':
        return Icons.arrow_upward_rounded;
      case 'transfer':
        return Icons.swap_horiz_rounded;
      case 'adjustment':
        return Icons.tune_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Stok Hareketleri',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedProductId,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  hint: const Text('Tüm Ürünler'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tüm Ürünler')),
                    ..._products.values.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProductId = value;
                    });
                    _loadData();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swap_horiz_rounded, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz hareket kaydı yok',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _transactions.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            final product = _products[transaction.productId];
                            final locationFrom = transaction.locationFromId != null
                                ? _locations[transaction.locationFromId]
                                : null;
                            final locationTo = transaction.locationToId != null
                                ? _locations[transaction.locationToId]
                                : null;
                            final typeColor = _getTransactionTypeColor(transaction.type);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: typeColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getTransactionTypeIcon(transaction.type),
                                            color: typeColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      product?.name ?? 'Bilinmeyen Ürün',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: typeColor.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      _getTransactionTypeLabel(transaction.type),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: typeColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.numbers_rounded, size: 14, color: Colors.grey[600]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${transaction.quantity.toStringAsFixed(2)} ${product?.unit ?? ""}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: typeColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (locationFrom != null || locationTo != null) ...[
                                                const SizedBox(height: 6),
                                                if (locationFrom != null)
                                                  Row(
                                                    children: [
                                                      Icon(Icons.arrow_upward_rounded, size: 12, color: Colors.grey[500]),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Kaynak: ${locationFrom.name}',
                                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                      ),
                                                    ],
                                                  ),
                                                if (locationTo != null)
                                                  Row(
                                                    children: [
                                                      Icon(Icons.arrow_downward_rounded, size: 12, color: Colors.grey[500]),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Hedef: ${locationTo.name}',
                                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                              if (transaction.note != null) ...[
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(Icons.note_rounded, size: 12, color: Colors.grey[500]),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        transaction.note!,
                                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    transaction.createdAt.toString().substring(0, 16),
                                                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
