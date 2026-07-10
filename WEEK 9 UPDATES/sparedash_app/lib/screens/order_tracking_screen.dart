import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';
import '../services/database_helper.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final email = dbProvider.currentEmail ?? 'guest@sparedash.com';
    final orders = await DatabaseHelper.instance.getOrdersByUser(email);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'shipped': return Colors.blue;
      case 'processing': return const Color(0xFFf59e0b);
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    await DatabaseHelper.instance.updateOrderStatus(orderId, newStatus);
    _loadOrders();
  }

  Future<void> _deleteOrder(int orderId) async {
    await DatabaseHelper.instance.deleteOrder(orderId);
    _loadOrders();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order removed'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Order Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(onPressed: _loadOrders, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : _orders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadOrders,
        color: const Color(0xFF2563EB),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _orders.length,
          itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Place an order from the cart to track it here',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String? ?? 'pending';
    final orderId = order['id'] as int;
    final partName = order['part_name'] as String? ?? 'Unknown Part';
    final quantity = order['quantity'] as int? ?? 1;
    final totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0.0;
    final seller = order['seller'] as String? ?? 'SpareDash Seller';
    final location = order['location'] as String? ?? 'Nairobi, Kenya';
    final createdAt = order['created_at'] as String? ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Order #$orderId',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Text(_formatDate(createdAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.car_repair, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(partName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Qty: $quantity',
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('KES ${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Color(0xFFf59e0b), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.store, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(seller,
                      style: const TextStyle(fontSize: 12, color: Colors.grey))),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location,
                      style: const TextStyle(fontSize: 12, color: Colors.grey))),
                ]),
                const SizedBox(height: 12),
                _buildTrackingSteps(status),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatusChip(orderId, 'processing', status)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildStatusChip(orderId, 'shipped', status)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildStatusChip(orderId, 'delivered', status)),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => _confirmDelete(orderId),
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

  Widget _buildTrackingSteps(String currentStatus) {
    final steps = ['pending', 'processing', 'shipped', 'delivered'];
    final currentIndex = steps.indexOf(currentStatus.toLowerCase());
    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isActive = index == currentIndex;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? _statusColor(steps[index]) : Colors.grey[300],
                    ),
                    child: Icon(isCompleted ? Icons.check : Icons.circle,
                        color: Colors.white, size: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index][0].toUpperCase() + steps[index].substring(1),
                    style: TextStyle(
                      fontSize: 9,
                      color: isActive ? _statusColor(steps[index]) : Colors.grey,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: index < currentIndex ? const Color(0xFF2563EB) : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusChip(int orderId, String status, String currentStatus) {
    final isActive = currentStatus.toLowerCase() == status;
    return GestureDetector(
      onTap: () => _updateStatus(orderId, status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _statusColor(status) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status[0].toUpperCase() + status.substring(1),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remove Order?'),
        content: const Text('Are you sure you want to remove this order from history?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _deleteOrder(orderId); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}