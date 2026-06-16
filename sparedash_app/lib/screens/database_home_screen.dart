import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';

class DatabaseHomeScreen extends StatefulWidget {
  const DatabaseHomeScreen({super.key});

  @override
  State<DatabaseHomeScreen> createState() => _DatabaseHomeScreenState();
}

class _DatabaseHomeScreenState extends State<DatabaseHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    await provider.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpareDash'),
        backgroundColor: const Color(0xFF2563EB),
        actions: [
          Consumer<DatabaseProvider>(
            builder: (context, provider, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cart screen coming soon!')),
                    );
                  },
                ),
                if (provider.cartCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf59e0b),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${provider.cartCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          if (provider.currentUser == null) {
            return const Center(child: Text('Please login'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadProducts();
              await provider.loadCart();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(provider),
                  const SizedBox(height: 20),

                  // Stats Row
                  _buildStatsRow(provider),
                  const SizedBox(height: 20),

                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 20),

                  // Products Section
                  const Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (provider.products.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.products.length > 4 ? 4 : provider.products.length,
                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        return _buildProductCard(product, provider);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(DatabaseProvider provider) {
    final user = provider.currentUser!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  user['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf59e0b),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${user['member_tier']} Member',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Color(0xFFf59e0b), size: 14),
                    Text(
                      ' ${user['loyalty_points']} pts',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DatabaseProvider provider) {
    final user = provider.currentUser!;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_bag_outlined,
            value: '${user['orderCount'] ?? 0}',
            label: 'Orders',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            value: 'KES ${((user['totalSpent'] ?? 0) / 1000).toStringAsFixed(0)}K',
            label: 'Spent',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            value: '${user['loyalty_points'] ?? 0}',
            label: 'Points',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 24),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search feature coming soon!')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Color(0xFF2563EB)),
            SizedBox(width: 12),
            Expanded(
              child: Text('Search parts...', style: TextStyle(color: Colors.grey)),
            ),
            Icon(Icons.tune, color: Color(0xFF2563EB)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, DatabaseProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.car_repair, size: 30, color: Color(0xFF2563EB)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KES ${product['price'].toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFf59e0b), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFf59e0b)),
                      const SizedBox(width: 4),
                      Text('${product['rating']}'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product['stock_quantity'] > 0 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product['stock_quantity'] > 0 ? 'In Stock' : 'Out of Stock',
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: product['stock_quantity'] > 0
                  ? () async {
                await provider.addToCart(product['id'], 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product['name']} added to cart'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
                  : null,
              icon: const Icon(Icons.add_shopping_cart),
              color: product['stock_quantity'] > 0 ? const Color(0xFF2563EB) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}