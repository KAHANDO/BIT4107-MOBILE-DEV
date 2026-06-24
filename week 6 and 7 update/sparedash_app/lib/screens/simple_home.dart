import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'shipping_screen.dart';
import 'profile_screen.dart';
import 'vehicle_search_screen.dart';
import 'order_tracking_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/database_provider.dart';
import '../services/database_helper.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  String _selectedCategory = 'Engine';
  String _greeting = '';

  final List<String> _categories = [
    'Engine',
    'Brakes',
    'Electric',
    'Body',
    'Suspension',
    'Transmission'
  ];

  List<Map<String, dynamic>> _currentParts = [];
  bool _isLoadingParts = false;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _loadParts('Engine');
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        _greeting = 'Good Morning';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon';
      } else {
        _greeting = 'Good Evening';
      }
    });
  }

  Future<void> _loadParts(String category) async {
    setState(() => _isLoadingParts = true);
    final parts =
    await DatabaseHelper.instance.getPartsByCategory(category);
    setState(() {
      _currentParts = parts;
      _isLoadingParts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider =
    Provider.of<DatabaseProvider>(context, listen: false);
    final userName = dbProvider.currentName ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpareDash'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          // Order tracking shortcut
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OrderTrackingScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf59e0b),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFf59e0b),
                    child:
                    Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_greeting,',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf59e0b),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Gold Member',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star,
                                color: Color(0xFFf59e0b), size: 14),
                            const Text(' 850 pts',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick action row
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.receipt_long,
                    label: 'My Orders',
                    color: const Color(0xFF2563EB),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const OrderTrackingScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.local_shipping,
                    label: 'Shipping',
                    color: const Color(0xFF1E40AF),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShippingScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.person,
                    label: 'Profile',
                    color: const Color(0xFFf59e0b),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vehicle Search Banner
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const VehicleSearchScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf59e0b), Color(0xFFd97706)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.directions_car,
                        color: Colors.white, size: 30),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search by Vehicle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Find parts for your specific car model',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CatalogScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                      const Color(0xFF2563EB).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF2563EB)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Search parts...',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    Icon(Icons.tune, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CatalogScreen()),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                        color: Color(0xFFf59e0b),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                      _loadParts(category);
                    },
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: Colors.grey[200],
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Parts Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_selectedCategory Parts',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CatalogScreen()),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                        color: Color(0xFFf59e0b),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Parts list from SQLite
            if (_isLoadingParts)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                      color: Color(0xFF2563EB)),
                ),
              )
            else if (_currentParts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No parts found in this category',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._currentParts.map((part) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPartCard(
                  context,
                  name: part['name'] as String,
                  price: part['price'] as String,
                  priceValue:
                  (part['price_value'] as num).toDouble(),
                  inStock: (part['in_stock'] as int) == 1,
                  seller: part['seller'] as String,
                  location: part['location'] as String,
                  rating: (part['rating'] as num).toDouble(),
                ),
              )),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildQuickAction(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartCard(
      BuildContext context, {
        required String name,
        required String price,
        required double priceValue,
        required bool inStock,
        required String seller,
        required String location,
        required double rating,
      }) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final quantity = cart.getItemQuantity(name);
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.car_repair,
                      size: 35, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(price,
                          style: const TextStyle(
                              color: Color(0xFFf59e0b),
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.store,
                              size: 11, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              seller,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 11, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: inStock
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius:
                              BorderRadius.circular(4),
                            ),
                            child: Text(
                              inStock
                                  ? 'In Stock'
                                  : 'Out of Stock',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.star,
                              size: 12,
                              color: Color(0xFFf59e0b)),
                          Text(' $rating',
                              style:
                              const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (quantity > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            cart.updateQuantity(
                                name, quantity - 1);
                          },
                          icon: const Icon(Icons.remove,
                              size: 18),
                          color: const Color(0xFF2563EB),
                        ),
                        Text('$quantity',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        IconButton(
                          onPressed: () {
                            cart.updateQuantity(
                                name, quantity + 1);
                          },
                          icon:
                          const Icon(Icons.add, size: 18),
                          color: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFf59e0b)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: inStock
                          ? () {
                        cart.addToCart(
                          id: name,
                          name: name,
                          price: price,
                          priceValue: priceValue,
                          inStock: inStock,
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                                '$name added to cart'),
                            duration: const Duration(
                                seconds: 1),
                            backgroundColor:
                            const Color(0xFF2563EB),
                          ),
                        );
                      }
                          : null,
                      icon: const Icon(
                          Icons.add_shopping_cart,
                          size: 20),
                      color: inStock
                          ? const Color(0xFFf59e0b)
                          : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFf59e0b),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          // Already on home
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CatalogScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CartScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                const OrderTrackingScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ProfileScreen()),
          );
        } else if (index == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                const VehicleSearchScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.category), label: 'Catalog'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long), label: 'Orders'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(
            icon: Icon(Icons.directions_car), label: 'Vehicles'),
      ],
    );
  }
}