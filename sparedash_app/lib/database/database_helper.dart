import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'sparedash.db');

    print('========== DATABASE INIT ==========');
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');

    // ========== USERS TABLE ==========
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        location TEXT,
        password TEXT NOT NULL,
        gender TEXT,
        profile_image TEXT,
        loyalty_points INTEGER DEFAULT 0,
        member_tier TEXT DEFAULT 'Bronze',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('✅ Users table created');

    // ========== CATEGORIES TABLE ==========
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('✅ Categories table created');

    // ========== PRODUCTS TABLE ==========
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_id INTEGER,
        price REAL NOT NULL,
        rating REAL DEFAULT 0,
        stock_quantity INTEGER DEFAULT 0,
        image_url TEXT,
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    print('✅ Products table created');

    // ========== CART TABLE ==========
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        product_id INTEGER,
        quantity INTEGER DEFAULT 1,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    print('✅ Cart table created');

    // ========== ORDERS TABLE ==========
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT UNIQUE NOT NULL,
        user_id INTEGER,
        total_amount REAL NOT NULL,
        delivery_fee REAL DEFAULT 500,
        status TEXT DEFAULT 'Pending',
        payment_method TEXT,
        shipping_address TEXT,
        order_date TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    print('✅ Orders table created');

    // ========== ORDER ITEMS TABLE ==========
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        product_id INTEGER,
        product_name TEXT,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    print('✅ Order items table created');

    // ========== SHIPPING REQUESTS TABLE ==========
    await db.execute('''
      CREATE TABLE shipping_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        part_name TEXT NOT NULL,
        brand TEXT,
        model TEXT,
        year TEXT,
        category TEXT,
        shipping_from TEXT,
        notes TEXT,
        status TEXT DEFAULT 'Pending',
        requested_date TEXT DEFAULT CURRENT_TIMESTAMP,
        quote_amount REAL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    print('✅ Shipping requests table created');

    // ========== LOYALTY TRANSACTIONS TABLE ==========
    await db.execute('''
      CREATE TABLE loyalty_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        points INTEGER,
        type TEXT,
        description TEXT,
        transaction_date TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    print('✅ Loyalty transactions table created');

    // ========== CREATE INDEXES ==========
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_cart_user_id ON cart(user_id)');
    await db.execute('CREATE INDEX idx_orders_user_id ON orders(user_id)');
    await db.execute('CREATE INDEX idx_products_category ON products(category_id)');
    await db.execute('CREATE INDEX idx_shipping_user_id ON shipping_requests(user_id)');
    print('✅ Indexes created');

    // ========== INSERT SAMPLE DATA ==========
    await _insertSampleData(db);

    print('🎉 Database created successfully with all tables!');
  }

  Future<void> _insertSampleData(Database db) async {
    print('Inserting sample data...');

    // Insert Categories
    List<Map<String, dynamic>> categories = [
      {'name': 'Engine Parts'},
      {'name': 'Brake System'},
      {'name': 'Electrical Parts'},
      {'name': 'Body Parts'},
      {'name': 'Suspension'},
      {'name': 'Transmission'},
    ];

    for (var category in categories) {
      await db.insert('categories', category);
    }
    print('✅ Categories inserted');

    // Insert Products
    List<Map<String, dynamic>> products = [
      {'name': 'Premium Brake Pads', 'category_id': 2, 'price': 3500, 'rating': 4.8, 'stock_quantity': 50, 'description': 'High-quality ceramic brake pads'},
      {'name': 'Engine Oil Filter', 'category_id': 1, 'price': 1200, 'rating': 4.6, 'stock_quantity': 100, 'description': 'Premium oil filter'},
      {'name': 'Alternator', 'category_id': 3, 'price': 8500, 'rating': 4.7, 'stock_quantity': 30, 'description': 'High-output alternator'},
      {'name': 'Shock Absorber', 'category_id': 5, 'price': 6200, 'rating': 4.5, 'stock_quantity': 0, 'description': 'Heavy-duty shock absorber'},
      {'name': 'Headlight Assembly', 'category_id': 4, 'price': 4800, 'rating': 4.4, 'stock_quantity': 25, 'description': 'LED headlight assembly'},
      {'name': 'Radiator', 'category_id': 1, 'price': 7200, 'rating': 4.4, 'stock_quantity': 15, 'description': 'Aluminum radiator'},
      {'name': 'Spark Plugs', 'category_id': 1, 'price': 1800, 'rating': 4.7, 'stock_quantity': 200, 'description': 'Iridium spark plugs'},
      {'name': 'Brake Rotors', 'category_id': 2, 'price': 4500, 'rating': 4.6, 'stock_quantity': 40, 'description': 'Drilled brake rotors'},
      {'name': 'Car Battery', 'category_id': 3, 'price': 12000, 'rating': 4.7, 'stock_quantity': 20, 'description': 'Maintenance-free battery'},
      {'name': 'Clutch Kit', 'category_id': 6, 'price': 11500, 'rating': 4.8, 'stock_quantity': 12, 'description': 'Complete clutch kit'},
    ];

    for (var product in products) {
      await db.insert('products', product);
    }
    print('✅ Products inserted');

    // Insert Demo User
    await db.insert('users', {
      'name': 'John Kamau',
      'email': 'demo@sparedash.com',
      'phone': '+254 712 345 678',
      'location': 'Nairobi, Kenya',
      'password': 'demo123',
      'gender': 'male',
      'profile_image': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      'loyalty_points': 850,
      'member_tier': 'Gold'
    });
    print('✅ Demo user inserted: demo@sparedash.com / demo123');
  }

  // ============ AUTHENTICATION METHODS ============

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    print('🔍 Looking for user: $email - Found: ${result.isNotEmpty}');
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> validateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null) {
      print('🔐 User found. Stored: ${user['password']} | Input: $password');
      return user['password'] == password;
    }
    print('❌ User not found: $email');
    return false;
  }

  // ============ USER OPERATIONS ============

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    user.remove('id');
    user['created_at'] = DateTime.now().toIso8601String();
    if (!user.containsKey('loyalty_points')) user['loyalty_points'] = 0;
    if (!user.containsKey('member_tier')) user['member_tier'] = 'Bronze';
    print('📝 Inserting user: ${user['email']}');
    return await db.insert('users', user);
  }

  Future<int> updateUser(int userId, Map<String, dynamic> userData) async {
    final db = await database;
    userData.remove('id');
    userData.remove('created_at');
    return await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ============ PRODUCT OPERATIONS ============

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<Map<String, dynamic>?> getProductById(int productId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ============ CART OPERATIONS ============

  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, p.name, p.price, p.image_url, p.stock_quantity
      FROM cart c
      JOIN products p ON c.product_id = p.id
      WHERE c.user_id = ?
    ''', [userId]);
  }

  Future<int> addToCart(int userId, int productId, int quantity) async {
    final db = await database;

    List<Map<String, dynamic>> existing = await db.query(
      'cart',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'cart',
        {'quantity': existing.first['quantity'] + quantity},
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
    } else {
      return await db.insert('cart', {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<int> updateCartQuantity(int cartId, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      return await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
    }
    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> removeFromCart(int cartId) async {
    final db = await database;
    return await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<int> clearCart(int userId) async {
    final db = await database;
    return await db.delete('cart', where: 'user_id = ?', whereArgs: [userId]);
  }

  // ============ ORDER OPERATIONS ============

  Future<String> createOrder(int userId, Map<String, dynamic> orderData) async {
    final db = await database;
    String orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';

    List<Map<String, dynamic>> cartItems = await getCartItems(userId);

    double total = 0;
    for (var item in cartItems) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }

    int orderId = await db.insert('orders', {
      'order_number': orderNumber,
      'user_id': userId,
      'total_amount': total,
      'delivery_fee': 500,
      'status': 'Pending',
      'payment_method': orderData['payment_method'],
      'shipping_address': orderData['shipping_address'],
    });

    for (var item in cartItems) {
      await db.insert('order_items', {
        'order_id': orderId,
        'product_id': item['product_id'],
        'product_name': item['name'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }

    int pointsEarned = (total / 100).floor();
    await addLoyaltyPoints(userId, pointsEarned);
    await clearCart(userId);

    return orderNumber;
  }

  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'order_date DESC',
    );
  }

  // ============ SHIPPING REQUEST OPERATIONS ============

  Future<int> insertShippingRequest(Map<String, dynamic> request) async {
    final db = await database;
    request.remove('id');
    request['requested_date'] = DateTime.now().toIso8601String();
    return await db.insert('shipping_requests', request);
  }

  Future<List<Map<String, dynamic>>> getUserShippingRequests(int userId) async {
    final db = await database;
    return await db.query(
      'shipping_requests',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'requested_date DESC',
    );
  }

  // ============ LOYALTY POINTS OPERATIONS ============

  Future<int> addLoyaltyPoints(int userId, int points) async {
    final db = await database;

    List<Map<String, dynamic>> user = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (user.isNotEmpty) {
      int currentPoints = user.first['loyalty_points'] ?? 0;
      int newPoints = currentPoints + points;

      String tier;
      if (newPoints >= 1000) {
        tier = 'Platinum';
      } else if (newPoints >= 500) {
        tier = 'Gold';
      } else {
        tier = 'Bronze';
      }

      return await db.update(
        'users',
        {'loyalty_points': newPoints, 'member_tier': tier},
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
    return 0;
  }

  // ============ STATISTICS OPERATIONS ============

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final db = await database;

    List<Map<String, dynamic>> orders = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    double totalSpent = 0;
    for (var order in orders) {
      totalSpent += order['total_amount'] ?? 0;
    }

    List<Map<String, dynamic>> user = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    return {
      'orderCount': orders.length,
      'totalSpent': totalSpent,
      'loyaltyPoints': user.isNotEmpty ? (user.first['loyalty_points'] ?? 0) : 0,
      'memberTier': user.isNotEmpty ? (user.first['member_tier'] ?? 'Bronze') : 'Bronze',
    };
  }

  // ============ UTILITY METHODS ============

  Future<void> printAllUsers() async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query('users');
    print('========== ALL USERS ==========');
    if (users.isEmpty) {
      print('❌ No users found!');
    } else {
      for (var user in users) {
        print('📧 ${user['email']} | 🔑 ${user['password']} | 👤 ${user['name']} | ⭐ ${user['loyalty_points']} pts');
      }
    }
    print('================================');
  }

  Future<String> getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, 'sparedash.db');
  }

  Future<int> getRecordCount(String tableName) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('products');
    await db.delete('cart');
    await db.delete('orders');
    await db.delete('order_items');
    await db.delete('shipping_requests');
    await db.delete('loyalty_transactions');
    print('All data deleted');
  }
}