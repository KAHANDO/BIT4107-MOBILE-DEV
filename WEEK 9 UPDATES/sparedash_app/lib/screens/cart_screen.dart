import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/database_provider.dart';
import '../services/database_helper.dart';
import '../services/gesture_handler.dart';
import 'simple_home.dart';
import 'catalog_screen.dart';
import 'shipping_screen.dart';
import 'profile_screen.dart';
import 'order_tracking_screen.dart';
import 'vehicle_search_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, item, cart);
                  },
                ),
              ),
              _buildTotalSection(context, cart),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 2),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Add items from the catalog',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CatalogScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Browse Catalog', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Swipe-to-delete cart item (Week 8 — gesture event)
  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cart) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Remove', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await GestureHandler.onSwipeToDelete(context: context, itemName: item.name);
      },
      onDismissed: (direction) {
        cart.updateQuantity(item.id, 0);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${item.name} removed from cart'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              cart.addToCart(
                id: item.id,
                name: item.name,
                price: item.price,
                priceValue: item.priceValue,
                inStock: true,
              );
            },
          ),
        ));
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
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
                    Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(item.price,
                        style: const TextStyle(
                            color: Color(0xFFf59e0b), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Swipe left to remove',
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => cart.updateQuantity(item.id, item.quantity - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: const Color(0xFF2563EB),
                    iconSize: 28,
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(item.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => cart.updateQuantity(item.id, item.quantity + 1),
                    icon: const Icon(Icons.add_circle_outline),
                    color: const Color(0xFF2563EB),
                    iconSize: 28,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', 'KES ${cart.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildTotalRow('Delivery Fee', 'KES ${cart.deliveryFee.toStringAsFixed(0)}'),
          const Divider(height: 24, thickness: 1),
          _buildTotalRow('Total', 'KES ${cart.total.toStringAsFixed(0)}', isTotal: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => _showCheckoutDialog(context, cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf59e0b),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? const Color(0xFFf59e0b) : Colors.black87)),
      ],
    );
  }

  Future<void> _showCheckoutDialog(BuildContext context, CartProvider cart) async {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final userEmail = dbProvider.currentEmail ?? 'guest@sparedash.com';

    for (final item in cart.items) {
      await DatabaseHelper.instance.placeOrder(
        userEmail: userEmail,
        partName: item.name,
        quantity: item.quantity,
        totalPrice: item.priceValue * item.quantity,
        seller: 'SpareDash Seller',
        location: 'Nairobi, Kenya',
      );
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Color(0xFFf59e0b), size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Order Confirmed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Total: KES ${cart.total.toStringAsFixed(0)}',
                style: const TextStyle(color: Color(0xFFf59e0b), fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Your order has been placed successfully!'),
            const SizedBox(height: 4),
            const Text('Track your order in Order History',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
              );
            },
            child: const Text('Home'),
          ),
          ElevatedButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrderTrackingScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Track Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SimpleHomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const CatalogScreen()));
        } else if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => OrderTrackingScreen()));
        } else if (index == 4) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()));
        } else if (index == 5) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => VehicleSearchScreen()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Catalog'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Vehicles'),
      ],
    );
  }
}