import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'simple_home.dart';
import 'cart_screen.dart';
import 'shipping_screen.dart';
import 'profile_screen.dart';
import '../providers/cart_provider.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF2563EB)),
                  SizedBox(width: 12),
                  Text('Search parts...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

          // Categories Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All', true),
                const SizedBox(width: 8),
                _buildFilterChip('Engine', false),
                const SizedBox(width: 8),
                _buildFilterChip('Brakes', false),
                const SizedBox(width: 8),
                _buildFilterChip('Electric', false),
                const SizedBox(width: 8),
                _buildFilterChip('Body', false),
                const SizedBox(width: 8),
                _buildFilterChip('Suspension', false),
                const SizedBox(width: 8),
                _buildFilterChip('Transmission', false),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('8 parts found', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Parts List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCatalogPartCard(context, 'Premium Brake Pads', 'Brakes', 'KES 3,500', 3500.0, 4.8, true),
                const SizedBox(height: 12),
                _buildCatalogPartCard(context, 'Engine Oil Filter', 'Engine', 'KES 1,200', 1200.0, 4.6, true),
                const SizedBox(height: 12),
                _buildCatalogPartCard(context, 'Alternator', 'Electric', 'KES 8,500', 8500.0, 4.7, true),
                const SizedBox(height: 12),
                _buildCatalogPartCard(context, 'Shock Absorber', 'Suspension', 'KES 6,200', 6200.0, 4.5, false),
                const SizedBox(height: 12),
                _buildCatalogPartCard(context, 'Headlight Assembly', 'Body', 'KES 4,800', 4800.0, 4.4, true),
                const SizedBox(height: 12),
                _buildCatalogPartCard(context, 'Radiator', 'Engine', 'KES 7,200', 7200.0, 4.4, true),
                const SizedBox(height: 12),
                _buildCatalogPartCard(context, 'Spark Plugs', 'Engine', 'KES 1,800', 1800.0, 4.7, true),
                const SizedBox(height: 12),
                _buildCatalogPartCard(context, 'Brake Rotors', 'Brakes', 'KES 4,500', 4500.0, 4.6, true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 1),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCatalogPartCard(BuildContext context, String name, String category, String price, double priceValue, double rating, bool inStock) {
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.car_repair, size: 40, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Color(0xFFf59e0b)),
                          const SizedBox(width: 4),
                          Text(rating.toString()),
                          const SizedBox(width: 8),
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
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFFf59e0b),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                          },
                          icon: const Icon(Icons.remove, size: 18),
                          color: const Color(0xFF2563EB),
                        ),
                        Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            cart.updateQuantity(name, quantity + 1);
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
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