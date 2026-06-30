import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'simple_home.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'shipping_screen.dart';
import 'login_screen.dart';
import '../providers/cart_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "John Kamau";
  String _userEmail = "john.kamau@email.com";
  String _userPhone = "+254 712 345 678";
  String _userLocation = "Nairobi, Kenya";
  int _loyaltyPoints = 850;
  int _ordersCompleted = 12;
  double _totalSpent = 94200;

  // Edit Profile controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Address controllers
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  List<Map<String, String>> _savedAddresses = [];
  List<Map<String, String>> _orderHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    _savedAddresses = [
      {'type': 'Home', 'address': '123 Kimathi Street, Nairobi, Kenya', 'isDefault': 'true'},
      {'type': 'Work', 'address': 'Westlands Business Park, Nairobi, Kenya', 'isDefault': 'false'},
    ];

    _orderHistory = [
      {'date': '2026-06-01', 'items': 'Premium Brake Pads', 'total': 'KES 3,500', 'status': 'Delivered'},
      {'date': '2026-05-28', 'items': 'Engine Oil Filter', 'total': 'KES 1,200', 'status': 'Delivered'},
      {'date': '2026-05-25', 'items': 'Alternator + Spark Plugs', 'total': 'KES 10,300', 'status': 'Shipped'},
    ];
  }

  void _showEditProfileDialog() {
    _nameController.text = _userName;
    _emailController.text = _userEmail;
    _phoneController.text = _userPhone;
    _locationController.text = _userLocation;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = _nameController.text;
                _userEmail = _emailController.text;
                _userPhone = _phoneController.text;
                _userLocation = _locationController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddressesDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('My Addresses'),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_savedAddresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No saved addresses'),
                    )
                  else
                    ..._savedAddresses.map((address) => ListTile(
                      leading: Icon(
                        address['type'] == 'Home' ? Icons.home : Icons.work,
                        color: const Color(0xFF2563EB),
                      ),
                      title: Text(address['type']!),
                      subtitle: Text(address['address']!),
                      trailing: address['isDefault'] == 'true'
                          ? const Chip(
                        label: Text('Default'),
                        backgroundColor: Color(0xFFf59e0b),
                        labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                      )
                          : IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setStateDialog(() {
                            _savedAddresses.remove(address);
                          });
                          setState(() {});
                        },
                      ),
                    )),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddAddressDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddAddressDialog() {
    _addressLineController.clear();
    _cityController.clear();
    _postalCodeController.clear();
    String selectedType = 'Home';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add New Address'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Address Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Home', child: Text('Home')),
                      DropdownMenuItem(value: 'Work', child: Text('Work')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressLineController,
                    decoration: const InputDecoration(
                      labelText: 'Address Line',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_addressLineController.text.isNotEmpty) {
                    setState(() {
                      _savedAddresses.add({
                        'type': selectedType,
                        'address': '${_addressLineController.text}, ${_cityController.text}, ${_postalCodeController.text}',
                        'isDefault': 'false',
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address added successfully!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Methods'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card, color: Color(0xFF2563EB)),
              title: const Text('Credit Card'),
              subtitle: const Text('**** **** **** 4242'),
              trailing: Radio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (value) {},
                activeColor: const Color(0xFFf59e0b),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Color(0xFF2563EB)),
              title: const Text('M-Pesa'),
              subtitle: const Text('+254 712 345 678'),
              trailing: Radio<int>(
                value: 2,
                groupValue: 1,
                onChanged: (value) {},
                activeColor: const Color(0xFFf59e0b),
              ),
            ),
            const Divider(),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOrderHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order History'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_orderHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No orders yet'),
                )
              else
                ..._orderHistory.map((order) => ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: order['status'] == 'Delivered'
                          ? Colors.green.withOpacity(0.1)
                          : const Color(0xFFf59e0b).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      order['status'] == 'Delivered'
                          ? Icons.check_circle
                          : Icons.local_shipping,
                      color: order['status'] == 'Delivered'
                          ? Colors.green
                          : const Color(0xFFf59e0b),
                      size: 20,
                    ),
                  ),
                  title: Text(order['items']!),
                  subtitle: Text(order['date']!),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order['total']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFf59e0b),
                        ),
                      ),
                      Text(
                        order['status']!,
                        style: TextStyle(
                          fontSize: 10,
                          color: order['status'] == 'Delivered'
                              ? Colors.green
                              : const Color(0xFFf59e0b),
                        ),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog() {
    bool pushEnabled = true;
    bool emailEnabled = true;
    bool smsEnabled = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Notifications'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive order updates'),
                  value: pushEnabled,
                  onChanged: (value) {
                    setStateDialog(() {
                      pushEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFF2563EB),
                ),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive promotional emails'),
                  value: emailEnabled,
                  onChanged: (value) {
                    setStateDialog(() {
                      emailEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFF2563EB),
                ),
                SwitchListTile(
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Receive order confirmations'),
                  value: smsEnabled,
                  onChanged: (value) {
                    setStateDialog(() {
                      smsEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFF2563EB),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification preferences saved!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFF2563EB)),
              title: const Text('Call Support'),
              subtitle: const Text('+254 700 123 456'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling support...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF2563EB)),
              title: const Text('Email Support'),
              subtitle: const Text('support@sparedash.com'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email app...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF2563EB)),
              title: const Text('Live Chat'),
              subtitle: const Text('Chat with an agent'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting live chat...')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.quiz, color: Color(0xFFf59e0b)),
              title: const Text('FAQs'),
              subtitle: const Text('Frequently asked questions'),
              onTap: () {
                Navigator.pop(context);
                _showFaqDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ListTile(
                title: Text('How to track my order?'),
                subtitle: Text('Go to Orders section in your profile'),
              ),
              Divider(),
              ListTile(
                title: Text('What is delivery time?'),
                subtitle: Text('2-5 business days for local delivery'),
              ),
              Divider(),
              ListTile(
                title: Text('How to return a part?'),
                subtitle: Text('Contact support within 7 days'),
              ),
              Divider(),
              ListTile(
                title: Text('How to earn loyalty points?'),
                subtitle: Text('Every KES 1000 spent = 10 points'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('We collect your name, email, phone number, and shipping address to process your orders.'),
              SizedBox(height: 12),
              Text(
                'Data Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Your data is used only for order processing and delivery notifications.'),
              SizedBox(height: 12),
              Text(
                'Data Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('We use industry-standard encryption to protect your personal information.'),
              SizedBox(height: 12),
              Text(
                'Third Parties',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('We never share your data with third parties without your consent.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            // Loyalty Card
            _buildLoyaltyCard(),

            // Stats Cards
            _buildStatsCards(),

            // Menu Items
            _buildMenuItems(),

            // Logout Button
            _buildLogoutButton(),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 4),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFf59e0b), width: 3),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFf59e0b),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Gold Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.white, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(_userEmail, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(_userPhone, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(_userLocation, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard() {
    double progress = _loyaltyPoints / 1000;
    int pointsNeeded = 1000 - _loyaltyPoints;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf59e0b), Color(0xFFd97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf59e0b).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Loyalty Rewards',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gold Member',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '$_loyaltyPoints / 1000 pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Next: Platinum',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '$pointsNeeded pts to go',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.white,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Earn ${1000 - _loyaltyPoints} more points to reach Platinum',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.shopping_bag_outlined,
              value: '$_ordersCompleted',
              label: 'Orders',
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.attach_money,
              value: 'KES ${(_totalSpent / 1000).toStringAsFixed(0)}K',
              label: 'Total Spent',
              color: const Color(0xFFf59e0b),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star,
              value: '$_loyaltyPoints',
              label: 'Points',
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Edit Profile',
        'subtitle': 'Update your personal information',
        'color': const Color(0xFF2563EB),
        'onTap': () => _showEditProfileDialog(),
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Addresses',
        'subtitle': 'Manage your shipping addresses',
        'color': const Color(0xFF2563EB),
        'onTap': () => _showAddressesDialog(),
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Payment Methods',
        'subtitle': 'Add or remove payment options',
        'color': const Color(0xFF2563EB),
        'onTap': () => _showPaymentMethodsDialog(),
      },
      {
        'icon': Icons.history,
        'title': 'Order History',
        'subtitle': 'View your past orders',
        'color': const Color(0xFFf59e0b),
        'onTap': () => _showOrderHistoryDialog(),
      },
      {
        'icon': Icons.notifications_none,
        'title': 'Notifications',
        'subtitle': 'Manage notification preferences',
        'color': const Color(0xFF2563EB),
        'onTap': () => _showNotificationsDialog(),
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'Get help with your orders',
        'color': const Color(0xFF2563EB),
        'onTap': () => _showHelpDialog(),
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'title': 'Privacy Policy',
        'subtitle': 'Read our privacy policy',
        'color': const Color(0xFF2563EB),
        'onTap': () => _showPrivacyDialog(),
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.menu, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...menuItems.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (item['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item['icon'] as IconData, color: item['color'] as Color),
      ),
      title: Text(
        item['title'] as String,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        item['subtitle'] as String,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: item['onTap'] as VoidCallback,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () {
            _showLogoutDialog();
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CatalogScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ShippingScreen()),
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