import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _productCount = 0;
  int _locationCount = 0;
  int _lowStockCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      final products = await DatabaseHelper.instance.getProducts();
      final locations = await DatabaseHelper.instance.getLocations();
      
      int lowStock = 0;
      for (var productMap in products) {
        final product = Product.fromMap(productMap);
        final inventory = await DatabaseHelper.instance.getInventoryForProduct(product.id!);
        double totalQty = 0;
        for (var inv in inventory) {
          totalQty += (inv['quantity'] as num).toDouble();
        }
        if (totalQty <= product.reorderLevel) {
          lowStock++;
        }
      }
      
      setState(() {
        _productCount = products.length;
        _locationCount = locations.length;
        _lowStockCount = lowStock;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Yönetim Sistemi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sistem Hakkında Bilgi Kartı
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stok Yönetim Sistemi',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ürün, stok ve lokasyon yönetimi için kapsamlı bir sistem',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            Icons.shopping_bag,
                            'Ürün Yönetimi',
                            'Ürün bilgileri, SKU, barkod ve fiyat takibi',
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            Icons.warehouse,
                            'Stok Takibi',
                            'Lokasyon bazlı stok miktarı ve rezervasyon yönetimi',
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            Icons.location_on,
                            'Lokasyon Yönetimi',
                            'Depo ve stok lokasyonlarının organizasyonu',
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            Icons.swap_horiz,
                            'Stok Hareketleri',
                            'Giriş, çıkış ve transfer işlemlerinin kaydı',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // İstatistikler
                  Text(
                    'İstatistikler',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Toplam Ürün',
                          _productCount.toString(),
                          Icons.inventory,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Lokasyon',
                          _locationCount.toString(),
                          Icons.place,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'Düşük Stoklu Ürünler',
                    _lowStockCount.toString(),
                    Icons.warning,
                    Colors.orange,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 24),
                  
                  // Hızlı Erişim
                  Text(
                    'Hızlı Erişim',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildQuickActionCard(
                        'Ürünler',
                        Icons.shopping_bag,
                        Colors.blue,
                        () {
                          // TODO: Navigate to products screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ürünler sayfası yakında eklenecek')),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Stok',
                        Icons.warehouse,
                        Colors.green,
                        () {
                          // TODO: Navigate to inventory screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Stok sayfası yakında eklenecek')),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Lokasyonlar',
                        Icons.location_on,
                        Colors.orange,
                        () {
                          // TODO: Navigate to locations screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lokasyonlar sayfası yakında eklenecek')),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Hareketler',
                        Icons.swap_horiz,
                        Colors.purple,
                        () {
                          // TODO: Navigate to transactions screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hareketler sayfası yakında eklenecek')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: fullWidth
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

