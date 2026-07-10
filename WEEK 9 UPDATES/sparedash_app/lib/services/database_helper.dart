import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sparedash.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS users');
        await db.execute('DROP TABLE IF EXISTS parts');
        await db.execute('DROP TABLE IF EXISTS orders');
        await _createTables(db, newVersion);
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE parts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price TEXT NOT NULL,
        price_value REAL NOT NULL,
        in_stock INTEGER NOT NULL DEFAULT 1,
        rating REAL NOT NULL DEFAULT 4.5,
        seller TEXT NOT NULL,
        location TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        part_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        seller TEXT NOT NULL DEFAULT 'Unknown',
        location TEXT NOT NULL DEFAULT 'Nairobi',
        created_at TEXT NOT NULL
      )
    ''');

    await db.insert('users', {
      'name': 'Demo User',
      'email': 'demo@sparedash.com',
      'password': 'demo123',
      'created_at': DateTime.now().toIso8601String(),
    });

    final List<Map<String, dynamic>> parts = [
      {'name': 'Toyota Hilux Engine Oil Filter', 'category': 'Engine', 'price': 'KES 850', 'price_value': 850.0, 'in_stock': 1, 'rating': 4.8, 'seller': 'Kamau Auto Spares', 'location': 'Kirinyaga Road, Nairobi'},
      {'name': 'Isuzu D-Max Alternator', 'category': 'Engine', 'price': 'KES 9,500', 'price_value': 9500.0, 'in_stock': 1, 'rating': 4.6, 'seller': 'Grogan Auto Parts', 'location': 'Grogan Road, Nairobi'},
      {'name': 'Nissan Navara Radiator', 'category': 'Engine', 'price': 'KES 7,800', 'price_value': 7800.0, 'in_stock': 1, 'rating': 4.5, 'seller': 'Kariuki Motors', 'location': 'Industrial Area, Nairobi'},
      {'name': 'Toyota Probox Spark Plugs (Set of 4)', 'category': 'Engine', 'price': 'KES 2,400', 'price_value': 2400.0, 'in_stock': 1, 'rating': 4.9, 'seller': 'Probox Spares Centre', 'location': 'Thika Road, Nairobi'},
      {'name': 'Subaru Forester Timing Belt Kit', 'category': 'Engine', 'price': 'KES 6,500', 'price_value': 6500.0, 'in_stock': 1, 'rating': 4.7, 'seller': 'Subaru Specialists Kenya', 'location': 'Ngong Road, Nairobi'},
      {'name': 'Mitsubishi Pajero Water Pump', 'category': 'Engine', 'price': 'KES 4,200', 'price_value': 4200.0, 'in_stock': 1, 'rating': 4.5, 'seller': 'Waweru Auto Spares', 'location': 'River Road, Nairobi'},
      {'name': 'Toyota Land Cruiser Brake Pads (Front)', 'category': 'Brakes', 'price': 'KES 4,500', 'price_value': 4500.0, 'in_stock': 1, 'rating': 4.8, 'seller': 'Landcruiser Spares Kenya', 'location': 'Ngong Road, Nairobi'},
      {'name': 'Nissan X-Trail Brake Discs (Pair)', 'category': 'Brakes', 'price': 'KES 6,800', 'price_value': 6800.0, 'in_stock': 1, 'rating': 4.6, 'seller': 'Mwangi Brake Centre', 'location': 'Industrial Area, Nairobi'},
      {'name': 'Brake Fluid DOT 4 (1 Litre)', 'category': 'Brakes', 'price': 'KES 650', 'price_value': 650.0, 'in_stock': 1, 'rating': 4.9, 'seller': 'Kamau Auto Spares', 'location': 'Kirinyaga Road, Nairobi'},
      {'name': 'Toyota Vitz Brake Caliper', 'category': 'Brakes', 'price': 'KES 3,200', 'price_value': 3200.0, 'in_stock': 1, 'rating': 4.7, 'seller': 'Vitz & Belta Spares', 'location': 'Kirinyaga Road, Nairobi'},
      {'name': 'Isuzu NQR Brake Drum', 'category': 'Brakes', 'price': 'KES 8,500', 'price_value': 8500.0, 'in_stock': 0, 'rating': 4.4, 'seller': 'Truck Parts Kenya', 'location': 'Lunga Lunga Road, Nairobi'},
      {'name': 'Amaron 12V 70Ah Car Battery', 'category': 'Electric', 'price': 'KES 13,500', 'price_value': 13500.0, 'in_stock': 1, 'rating': 4.9, 'seller': 'Battery World Kenya', 'location': 'Westlands, Nairobi'},
      {'name': 'Toyota Corolla Starter Motor', 'category': 'Electric', 'price': 'KES 8,200', 'price_value': 8200.0, 'in_stock': 1, 'rating': 4.6, 'seller': 'Electrical Auto Parts', 'location': 'Grogan Road, Nairobi'},
      {'name': 'Subaru Legacy Alternator', 'category': 'Electric', 'price': 'KES 11,000', 'price_value': 11000.0, 'in_stock': 1, 'rating': 4.5, 'seller': 'Subaru Specialists Kenya', 'location': 'Ngong Road, Nairobi'},
      {'name': 'Universal Car Fuse Box 12-Way', 'category': 'Electric', 'price': 'KES 1,800', 'price_value': 1800.0, 'in_stock': 1, 'rating': 4.7, 'seller': 'Waweru Auto Spares', 'location': 'River Road, Nairobi'},
      {'name': 'Toyota Hilux Headlight Assembly (Left)', 'category': 'Electric', 'price': 'KES 5,500', 'price_value': 5500.0, 'in_stock': 1, 'rating': 4.6, 'seller': 'Hilux Parts Centre', 'location': 'Thika Road, Nairobi'},
      {'name': 'Toyota Harrier Side Mirror (Right)', 'category': 'Body', 'price': 'KES 4,800', 'price_value': 4800.0, 'in_stock': 1, 'rating': 4.5, 'seller': 'Harrier & Prado Parts', 'location': 'South B, Nairobi'},
      {'name': 'Nissan Premio Front Bumper', 'category': 'Body', 'price': 'KES 12,000', 'price_value': 12000.0, 'in_stock': 0, 'rating': 4.3, 'seller': 'Premio Body Parts', 'location': 'Industrial Area, Nairobi'},
      {'name': 'Toyota Fielder Door Handle (Front Left)', 'category': 'Body', 'price': 'KES 1,200', 'price_value': 1200.0, 'in_stock': 1, 'rating': 4.8, 'seller': 'Fielder Spares Kenya', 'location': 'Kirinyaga Road, Nairobi'},
      {'name': 'Isuzu D-Max Bonnet', 'category': 'Body', 'price': 'KES 18,500', 'price_value': 18500.0, 'in_stock': 1, 'rating': 4.4, 'seller': 'Truck Parts Kenya', 'location': 'Lunga Lunga Road, Nairobi'},
      {'name': 'Toyota Prado Windscreen', 'category': 'Body', 'price': 'KES 22,000', 'price_value': 22000.0, 'in_stock': 1, 'rating': 4.6, 'seller': 'Landcruiser Spares Kenya', 'location': 'Ngong Road, Nairobi'},
      {'name': 'Toyota Hilux Shock Absorber (Rear)', 'category': 'Suspension', 'price': 'KES 7,500', 'price_value': 7500.0, 'in_stock': 1, 'rating': 4.7, 'seller': 'Hilux Parts Centre', 'location': 'Thika Road, Nairobi'},
      {'name': 'Subaru Outback Coil Spring (Front)', 'category': 'Suspension', 'price': 'KES 5,200', 'price_value': 5200.0, 'in_stock': 1, 'rating': 4.6, 'seller': 'Subaru Specialists Kenya', 'location': 'Ngong Road, Nairobi'},
      {'name': 'Toyota RAV4 Control Arm (Left)', 'category': 'Suspension', 'price': 'KES 9,800', 'price_value': 9800.0, 'in_stock': 1, 'rating': 4.5, 'seller': 'RAV4 & SUV Spares', 'location': 'Mombasa Road, Nairobi'},
      {'name': 'Nissan Tiida Ball Joint (Front)', 'category': 'Suspension', 'price': 'KES 2,800', 'price_value': 2800.0, 'in_stock': 1, 'rating': 4.8, 'seller': 'Kariuki Motors', 'location': 'Industrial Area, Nairobi'},
      {'name': 'Toyota Prado Stabilizer Bar Link', 'category': 'Suspension', 'price': 'KES 3,500', 'price_value': 3500.0, 'in_stock': 0, 'rating': 4.4, 'seller': 'Landcruiser Spares Kenya', 'location': 'Ngong Road, Nairobi'},
      {'name': 'Toyota Automatic Transmission Fluid ATF (4L)', 'category': 'Transmission', 'price': 'KES 3,200', 'price_value': 3200.0, 'in_stock': 1, 'rating': 4.9, 'seller': 'Kamau Auto Spares', 'location': 'Kirinyaga Road, Nairobi'},
      {'name': 'Isuzu NHR Clutch Kit', 'category': 'Transmission', 'price': 'KES 14,500', 'price_value': 14500.0, 'in_stock': 1, 'rating': 4.7, 'seller': 'Truck Parts Kenya', 'location': 'Lunga Lunga Road, Nairobi'},
      {'name': 'Nissan Navara Gearbox', 'category': 'Transmission', 'price': 'KES 45,000', 'price_value': 45000.0, 'in_stock': 0, 'rating': 4.3, 'seller': 'Grogan Auto Parts', 'location': 'Grogan Road, Nairobi'},
      {'name': 'Toyota Corolla Transmission Filter', 'category': 'Transmission', 'price': 'KES 1,500', 'price_value': 1500.0, 'in_stock': 1, 'rating': 4.8, 'seller': 'Probox Spares Centre', 'location': 'Thika Road, Nairobi'},
      {'name': 'Subaru Impreza Transfer Case', 'category': 'Transmission', 'price': 'KES 28,000', 'price_value': 28000.0, 'in_stock': 1, 'rating': 4.5, 'seller': 'Subaru Specialists Kenya', 'location': 'Ngong Road, Nairobi'},
    ];

    for (final part in parts) {
      await db.insert('parts', part);
    }
  }

  Future<bool> registerUser(String name, String email, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'name': name,
        'email': email.toLowerCase(),
        'password': password,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final results = await db.query('users',
        where: 'email = ? AND password = ?',
        whereArgs: [email.toLowerCase(), password],
        limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query('users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
        limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllParts() async {
    final db = await database;
    return await db.query('parts', orderBy: 'category, name');
  }

  Future<List<Map<String, dynamic>>> getPartsByCategory(String category) async {
    final db = await database;
    return await db.query('parts', where: 'category = ?', whereArgs: [category]);
  }

  Future<List<Map<String, dynamic>>> searchParts(String query) async {
    final db = await database;
    return await db.query('parts',
        where: 'name LIKE ? OR category LIKE ? OR seller LIKE ? OR location LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%']);
  }

  Future<int> placeOrder({
    required String userEmail,
    required String partName,
    required int quantity,
    required double totalPrice,
    String seller = 'Unknown',
    String location = 'Nairobi',
  }) async {
    final db = await database;
    return await db.insert('orders', {
      'user_email': userEmail,
      'part_name': partName,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': 'pending',
      'seller': seller,
      'location': location,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getOrdersByUser(String email) async {
    final db = await database;
    return await db.query('orders',
        where: 'user_email = ?',
        whereArgs: [email],
        orderBy: 'created_at DESC');
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    final db = await database;
    return await db.update('orders', {'status': status},
        where: 'id = ?', whereArgs: [orderId]);
  }

  Future<int> deleteOrder(int orderId) async {
    final db = await database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}