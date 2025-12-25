import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final productsData = await DatabaseHelper.instance.getProducts();
      setState(() {
        _products = productsData.map((p) => Product.fromMap(p)).toList();
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

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ürünü Sil'),
        content: Text('${product.name} ürününü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && product.id != null) {
      try {
        await DatabaseHelper.instance.deleteProduct(product.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ürün silindi'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadProducts();
        }
      } catch (e) {
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
  }

  void _showProductDialog({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final skuController = TextEditingController(text: product?.sku ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final unitController = TextEditingController(text: product?.unit ?? '');
    final barcodeController = TextEditingController(text: product?.barcode ?? '');
    final reorderLevelController = TextEditingController(text: product?.reorderLevel.toString() ?? '0');
    final costPriceController = TextEditingController(text: product?.costPrice?.toString() ?? '');
    final salePriceController = TextEditingController(text: product?.salePrice?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        product == null ? Icons.add_rounded : Icons.edit_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product == null ? 'Yeni Ürün Ekle' : 'Ürünü Düzenle',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Ürün Adı *',
                    prefixIcon: const Icon(Icons.shopping_bag_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: skuController,
                  decoration: InputDecoration(
                    labelText: 'SKU',
                    prefixIcon: const Icon(Icons.qr_code_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    prefixIcon: const Icon(Icons.description_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(
                    labelText: 'Birim *',
                    prefixIcon: const Icon(Icons.straighten_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Barkod',
                    prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: reorderLevelController,
                        decoration: InputDecoration(
                          labelText: 'Min. Stok',
                          prefixIcon: const Icon(Icons.warning_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: costPriceController,
                        decoration: InputDecoration(
                          labelText: 'Maliyet Fiyatı',
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: salePriceController,
                        decoration: InputDecoration(
                          labelText: 'Satış Fiyatı',
                          prefixIcon: const Icon(Icons.sell_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty || unitController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ürün adı ve birim zorunludur'),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final productMap = {
                          'name': nameController.text.trim(),
                          'sku': skuController.text.trim().isEmpty ? null : skuController.text.trim(),
                          'description': descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                          'unit': unitController.text.trim(),
                          'barcode': barcodeController.text.trim().isEmpty ? null : barcodeController.text.trim(),
                          'reorder_level': int.tryParse(reorderLevelController.text) ?? 0,
                          'cost_price': costPriceController.text.trim().isEmpty ? null : double.tryParse(costPriceController.text),
                          'sale_price': salePriceController.text.trim().isEmpty ? null : double.tryParse(salePriceController.text),
                        };

                        try {
                          if (product == null) {
                            await DatabaseHelper.instance.insertProduct(productMap);
                          } else if (product.id != null) {
                            await DatabaseHelper.instance.updateProduct(product.id!, productMap);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            _loadProducts();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Hata: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(product == null ? Icons.add_rounded : Icons.check_rounded),
                      label: Text(product == null ? 'Ekle' : 'Güncelle'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Product> get _filteredProducts {
    if (_searchController.text.isEmpty) return _products;
    final query = _searchController.text.toLowerCase();
    return _products.where((p) {
      return p.name.toLowerCase().contains(query) ||
          (p.sku?.toLowerCase().contains(query) ?? false) ||
          (p.barcode?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Ürünler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadProducts,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_rounded, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty ? 'Henüz ürün yok' : 'Sonuç bulunamadı',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _showProductDialog(),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('İlk ürünü ekle'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          itemCount: _filteredProducts.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
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
                                  onTap: () => _showProductDialog(product: product),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.withValues(alpha: 0.2),
                                                Colors.blue.withValues(alpha: 0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.shopping_bag_rounded,
                                            color: Colors.blue,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 12,
                                                children: [
                                                  if (product.sku != null)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.qr_code_rounded, size: 14, color: Colors.grey[600]),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          product.sku!,
                                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                        ),
                                                      ],
                                                    ),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.straighten_rounded, size: 14, color: Colors.grey[600]),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        product.unit,
                                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                      ),
                                                    ],
                                                  ),
                                                  if (product.salePrice != null)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.sell_rounded, size: 14, color: Colors.green),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${product.salePrice!.toStringAsFixed(2)} ₺',
                                                          style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.edit_rounded, size: 20),
                                                  SizedBox(width: 8),
                                                  Text('Düzenle'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Sil', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showProductDialog(product: product);
                                            } else if (value == 'delete') {
                                              _deleteProduct(product);
                                            }
                                          },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Ürün'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
