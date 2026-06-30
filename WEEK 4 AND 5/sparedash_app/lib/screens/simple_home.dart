import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'shipping_screen.dart';
import 'profile_screen.dart';
import '../providers/cart_provider.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  String _selectedCategory = 'Engine';
  String _greeting = '';
  String _userName = 'John Kamau';

  final List<String> _categories = ['Engine', 'Brakes', 'Electric', 'Body', 'Suspension', 'Transmission'];

  // Parts data by category - using proper types
  final Map<String, List<Map<String, dynamic>>> _partsByCategory = {
    'Engine': [
      {'name': 'Engine Oil Filter', 'price': 'KES 1,200', 'priceValue': 1200.0, 'inStock': true},
      {'name': 'Alternator', 'price': 'KES 8,500', 'priceValue': 8500.0, 'inStock': true},
      {'name': 'Radiator', 'price': 'KES 7,200', 'priceValue': 7200.0, 'inStock': true},
      {'name': 'Spark Plugs', 'price': 'KES 1,800', 'priceValue': 1800.0, 'inStock': true},
    ],
    'Brakes': [
      {'name': 'Premium Brake Pads', 'price': 'KES 3,500', 'priceValue': 3500.0, 'inStock': true},
      {'name': 'Brake Rotors', 'price': 'KES 4,500', 'priceValue': 4500.0, 'inStock': true},
      {'name': 'Brake Calipers', 'price': 'KES 6,200', 'priceValue': 6200.0, 'inStock': true},
      {'name': 'Brake Fluid', 'price': 'KES 800', 'priceValue': 800.0, 'inStock': true},
    ],
    'Electric': [
      {'name': 'Car Battery', 'price': 'KES 12,000', 'priceValue': 12000.0, 'inStock': true},
      {'name': 'Alternator', 'price': 'KES 8,500', 'priceValue': 8500.0, 'inStock': true},
      {'name': 'Starter Motor', 'price': 'KES 7,500', 'priceValue': 7500.0, 'inStock': true},
      {'name': 'Fuse Box', 'price': 'KES 2,500', 'priceValue': 2500.0, 'inStock': true},
    ],
    'Body': [
      {'name': 'Headlight Assembly', 'price': 'KES 4,800', 'priceValue': 4800.0, 'inStock': true},
      {'name': 'Side Mirror', 'price': 'KES 3,200', 'priceValue': 3200.0, 'inStock': true},
      {'name': 'Bumper', 'price': 'KES 9,500', 'priceValue': 9500.0, 'inStock': false},
      {'name': 'Door Handle', 'price': 'KES 1,500', 'priceValue': 1500.0, 'inStock': true},
    ],
    'Suspension': [
      {'name': 'Shock Absorber', 'price': 'KES 6,200', 'priceValue': 6200.0, 'inStock': false},
      {'name': 'Coil Spring', 'price': 'KES 4,500', 'priceValue': 4500.0, 'inStock': true},
      {'name': 'Control Arm', 'price': 'KES 7,800', 'priceValue': 7800.0, 'inStock': true},
      {'name': 'Ball Joint', 'price': 'KES 2,200', 'priceValue': 2200.0, 'inStock': true},
    ],
    'Transmission': [
      {'name': 'Transmission Fluid', 'price': 'KES 2,800', 'priceValue': 2800.0, 'inStock': true},
      {'name': 'Clutch Kit', 'price': 'KES 11,500', 'priceValue': 11500.0, 'inStock': true},
      {'name': 'Gearbox', 'price': 'KES 25,000', 'priceValue': 25000.0, 'inStock': false},
      {'name': 'Transmission Filter', 'price': 'KES 1,800', 'priceValue': 1800.0, 'inStock': true},
    ],
  };

  @override
  void initState() {
    super.initState();
    _updateGreeting();
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

  List<Map<String, dynamic>> get _currentCategoryParts {
    return _partsByCategory[_selectedCategory] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpareDash'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
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
            // Welcome Card with Time Greeting
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
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_greeting,',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userName,
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf59e0b),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Gold Member',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: Color(0xFFf59e0b), size: 14),
                            const Text(' 850 pts', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Weather Widget
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFf59e0b), Color(0xFFd97706)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.white, size: 30),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '18°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text('Partly sunny', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.location_on, color: Colors.white70, size: 16),
                  Text(' Nairobi', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CatalogScreen()),
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
            ),
            const SizedBox(height: 20),

            // Categories Section with All Active Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CatalogScreen()),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Color(0xFFf59e0b), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Scrollable Categories Chips
            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Showing $category parts'),
                          duration: const Duration(milliseconds: 800),
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                      );
                    },
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: Colors.grey[200],
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic Parts Section based on Selected Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_selectedCategory Parts',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CatalogScreen()),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Color(0xFFf59e0b), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Display parts for selected category
            ..._currentCategoryParts.map((part) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPartCard(
                context,
                part['name'] as String,
                part['price'] as String,
                part['priceValue'] as double,
                part['inStock'] as bool,
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 0),
    );
  }

  Widget _buildPartCard(BuildContext context, String name, String price, double priceValue, bool inStock) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final quantity = cart.getItemQuantity(name);
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  child: const Icon(Icons.car_repair, size: 35, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(price, style: const TextStyle(color: Color(0xFFf59e0b), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: inStock ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              inStock ? 'In Stock' : 'Out of Stock',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, size: 14, color: Color(0xFFf59e0b)),
                          const Text(' 4.7', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (quantity > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            cart.updateQuantity(name, quantity - 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Removed from cart'), duration: Duration(seconds: 1)),
                            );
                          },
                          icon: const Icon(Icons.remove, size: 18),
                          color: const Color(0xFF2563EB),
                        ),
                        Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        IconButton(
                          onPressed: () {
                            cart.updateQuantity(name, quantity + 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1)),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          color: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFf59e0b).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: inStock ? () {
                        cart.addToCart(
                          id: name,
                          name: name,
                          price: price,
                          priceValue: priceValue,
                          inStock: inStock,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$name added to cart'), duration: const Duration(seconds: 1)),
                        );
                      } : null,
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      color: inStock ? const Color(0xFFf59e0b) : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFf59e0b),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          // Already on home
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CatalogScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShippingScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Catalog'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Ship'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}