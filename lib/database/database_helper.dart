import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('safefood.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Bumped version to force recreation
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create coupons table if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS coupons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT UNIQUE NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          discount_percentage INTEGER NOT NULL,
          max_discount REAL,
          min_purchase REAL DEFAULT 0,
          valid_from TEXT NOT NULL,
          valid_until TEXT NOT NULL,
          max_usage INTEGER NOT NULL,
          used_count INTEGER DEFAULT 0,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL
        )
      ''');

      // Create user_coupons table if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_coupons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          coupon_id INTEGER NOT NULL,
          claimed_at TEXT NOT NULL,
          is_used INTEGER DEFAULT 0,
          used_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (coupon_id) REFERENCES coupons (id)
        )
      ''');

      // Try to add columns (will fail silently if already exists)
      try {
        await db.execute('ALTER TABLE orders ADD COLUMN payment_method TEXT DEFAULT \'cod\'');
      } catch (_) {}
      
      try {
        await db.execute('ALTER TABLE orders ADD COLUMN coupon_id INTEGER');
      } catch (_) {}
      
      try {
        await db.execute('ALTER TABLE orders ADD COLUMN discount_amount REAL DEFAULT 0');
      } catch (_) {}
      
      try {
        await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT');
      } catch (_) {}
    }
    
    if (oldVersion < 3) {
      // Version 3: Ensure coupon tables exist
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS coupons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            discount_percentage INTEGER NOT NULL,
            max_discount REAL,
            min_purchase REAL DEFAULT 0,
            valid_from TEXT NOT NULL,
            valid_until TEXT NOT NULL,
            max_usage INTEGER NOT NULL,
            used_count INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');
      } catch (_) {}

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_coupons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            coupon_id INTEGER NOT NULL,
            claimed_at TEXT NOT NULL,
            is_used INTEGER DEFAULT 0,
            used_at TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id),
            FOREIGN KEY (coupon_id) REFERENCES coupons (id)
          )
        ''');
      } catch (_) {}
      
      // Insert dummy data safely
      await _insertDummyData(db);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Table Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Table Bakeries
    await db.execute('''
      CREATE TABLE bakeries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        phone TEXT,
        image_url TEXT,
        rating REAL DEFAULT 0.0,
        opening_time TEXT,
        closing_time TEXT,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table Products (Surprise Packages)
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bakery_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        original_price REAL NOT NULL,
        discount_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        image_url TEXT,
        available_from TEXT,
        available_until TEXT,
        is_available INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (bakery_id) REFERENCES bakeries (id)
      )
    ''');

    // Table Orders
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        bakery_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        status TEXT NOT NULL,
        pickup_time TEXT,
        order_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (bakery_id) REFERENCES bakeries (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Insert dummy data for testing
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    // Check if data already exists
    final existingBakeries = await db.query('bakeries', limit: 1);
    if (existingBakeries.isNotEmpty) {
      return; // Data already inserted, skip
    }

    // Insert dummy bakeries with actual GPS location
    await db.insert('bakeries', {
      'name': 'Roti Bakar 88',
      'description': 'Bakery premium dengan berbagai pilihan roti segar',
      'address': 'Jl. MT Haryono No. 123, Balikpapan',
      'latitude': -1.1453847,
      'longitude': 116.8799866,
      'phone': '081234567890',
      'image_url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&h=400&fit=crop',
      'rating': 4.5,
      'opening_time': '07:00',
      'closing_time': '20:00',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('bakeries', {
      'name': 'Bread & Butter',
      'description': 'Artisan bakery dengan produk organik',
      'address': 'Jl. Gatot Subroto No. 45, Balikpapan',
      'latitude': -1.1420000,
      'longitude': 116.8820000,
      'phone': '081234567891',
      'image_url': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800&h=400&fit=crop',
      'rating': 4.8,
      'opening_time': '06:00',
      'closing_time': '21:00',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('bakeries', {
      'name': 'The French Bakery',
      'description': 'Pastry & croissant ala Perancis',
      'address': 'Jl. Soekarno Hatta No. 78, Balikpapan',
      'latitude': -1.1480000,
      'longitude': 116.8780000,
      'phone': '081234567892',
      'image_url': 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?w=800&h=400&fit=crop',
      'rating': 4.7,
      'opening_time': '07:30',
      'closing_time': '19:00',
      'created_at': DateTime.now().toIso8601String(),
    });

    // 5 TOKO BARU dengan koordinat real Balikpapan
    await db.insert('bakeries', {
      'name': 'Kopi & Roti Kita',
      'description': 'Bakery lokal dengan menu fusion Indonesia-Barat',
      'address': 'Jl. Ahmad Yani No. 92, Balikpapan',
      'latitude': -1.1388500,
      'longitude': 116.8653200,
      'phone': '081234567893',
      'image_url': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&h=400&fit=crop',
      'rating': 4.6,
      'opening_time': '06:30',
      'closing_time': '22:00',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('bakeries', {
      'name': 'Golden Crust Bakehouse',
      'description': 'Spesialis roti manis dan cake custom',
      'address': 'Jl. Jenderal Sudirman No. 156, Balikpapan',
      'latitude': -1.1502300,
      'longitude': 116.8711400,
      'phone': '081234567894',
      'image_url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&h=400&fit=crop',
      'rating': 4.9,
      'opening_time': '07:00',
      'closing_time': '21:00',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('bakeries', {
      'name': 'Sunrise Bakery & Cafe',
      'description': 'Bakery dengan view laut, sarapan terbaik di kota',
      'address': 'Jl. Mulawarman No. 23, Balikpapan',
      'latitude': -1.1556700,
      'longitude': 116.8934500,
      'phone': '081234567895',
      'image_url': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800&h=400&fit=crop',
      'rating': 4.8,
      'opening_time': '05:30',
      'closing_time': '20:00',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('bakeries', {
      'name': 'Artisan Sourdough Lab',
      'description': 'Sourdough artisan dan roti fermentasi alami',
      'address': 'Jl. Pierre Tendean No. 88, Balikpapan',
      'latitude': -1.1441200,
      'longitude': 116.8756300,
      'phone': '081234567896',
      'image_url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&h=400&fit=crop',
      'rating': 4.9,
      'opening_time': '08:00',
      'closing_time': '19:00',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('bakeries', {
      'name': 'Sweet Moments Patisserie',
      'description': 'Patisserie modern dengan dessert box premium',
      'address': 'Jl. Sultan Hasanuddin No. 67, Balikpapan',
      'latitude': -1.1367800,
      'longitude': 116.8596700,
      'phone': '081234567897',
      'image_url': 'https://images.unsplash.com/photo-1519915212116-7cfef71f1d3e?w=800&h=400&fit=crop',
      'rating': 4.7,
      'opening_time': '09:00',
      'closing_time': '21:00',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert dummy surprise packages with realistic French bakery names
    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Croissant & Danish Box',
      'description': 'Paket berisi 4-5 croissant butter, pain au chocolat, dan danish pastry segar dari produksi pagi',
      'original_price': 85000.0,
      'discount_price': 38000.0,
      'quantity': 12,
      'image_url': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=300&fit=crop',
      'available_from': '07:00',
      'available_until': '12:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Baguette & Sourdough Package',
      'description': 'Paket berisi 2-3 baguette premium dan sourdough artisan dari produksi hari ini',
      'original_price': 95000.0,
      'discount_price': 42000.0,
      'quantity': 8,
      'image_url': 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400&h=300&fit=crop',
      'available_from': '17:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Macaron & Eclair Surprise',
      'description': 'Paket berisi 6-8 macaron berbagai rasa dan eclair premium isi random',
      'original_price': 110000.0,
      'discount_price': 52000.0,
      'quantity': 6,
      'image_url': 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=400&h=300&fit=crop',
      'available_from': '18:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Donat Glazed Mix',
      'description': 'Paket berisi 8-10 donat glazed berbagai rasa: coklat, strawberry, vanilla, matcha',
      'original_price': 75000.0,
      'discount_price': 35000.0,
      'quantity': 15,
      'image_url': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Roti Tawar Premium',
      'description': 'Roti tawar gandum utuh premium, lembut dan fresh untuk sarapan keluarga',
      'original_price': 45000.0,
      'discount_price': 25000.0,
      'quantity': 20,
      'image_url': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=300&fit=crop',
      'available_from': '07:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 2,
      'name': 'Pain au Chocolat Box',
      'description': 'Paket berisi 5-6 pain au chocolat organik dengan cokelat premium Valrhona',
      'original_price': 125000.0,
      'discount_price': 55000.0,
      'quantity': 10,
      'image_url': 'https://images.unsplash.com/photo-1623334044303-241021148842?w=400&h=300&fit=crop',
      'available_from': '18:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 2,
      'name': 'Artisan Bread Bundle',
      'description': 'Paket berisi 3-4 roti artisan organik: multigrain, ciabatta, focaccia, dan rye bread',
      'original_price': 140000.0,
      'discount_price': 65000.0,
      'quantity': 7,
      'image_url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop',
      'available_from': '17:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 2,
      'name': 'Bagel Sandwich Pack',
      'description': 'Paket 4 bagel dengan cream cheese, smoked salmon, dan sayuran segar organik',
      'original_price': 90000.0,
      'discount_price': 45000.0,
      'quantity': 12,
      'image_url': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=300&fit=crop',
      'available_from': '09:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 2,
      'name': 'Muffin Blueberry Box',
      'description': 'Paket 6 muffin blueberry organik dengan topping crumble renyah',
      'original_price': 80000.0,
      'discount_price': 40000.0,
      'quantity': 10,
      'image_url': 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 3,
      'name': 'Mille-feuille & Tarte Package',
      'description': 'Paket berisi 2-3 slice mille-feuille dan fruit tarte ala Perancis',
      'original_price': 135000.0,
      'discount_price': 62000.0,
      'quantity': 5,
      'image_url': 'https://images.unsplash.com/photo-1519915212116-7cfef71f1d3e?w=400&h=300&fit=crop',
      'available_from': '16:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 3,
      'name': 'Croissant Almond & Chausson',
      'description': 'Paket berisi 4-5 croissant almond dan chausson aux pommes (apple turnover) khas Perancis',
      'original_price': 105000.0,
      'discount_price': 48000.0,
      'quantity': 9,
      'image_url': 'https://images.unsplash.com/photo-1530610476181-d83430b64dcd?w=400&h=300&fit=crop',
      'available_from': '07:30',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 3,
      'name': 'Brioche & Pain de Mie',
      'description': 'Paket roti brioche French butter dan pain de mie premium untuk sandwich mewah',
      'original_price': 95000.0,
      'discount_price': 48000.0,
      'quantity': 11,
      'image_url': 'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 3,
      'name': 'Canelé & Financier Box',
      'description': 'Paket dessert Perancis: canelé caramelized dan financier almond premium',
      'original_price': 120000.0,
      'discount_price': 60000.0,
      'quantity': 8,
      'image_url': 'https://images.unsplash.com/photo-1587241321921-91a834d82ffc?w=400&h=300&fit=crop',
      'available_from': '10:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // PRODUK TAMBAHAN - Lebih banyak variasi
    
    // Roti Bakar 88 - Additional Products
    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Kue Pisang & Brownies Mix',
      'description': 'Paket kue pisang coklat, brownies fudge, dan banana walnut loaf',
      'original_price': 65000.0,
      'discount_price': 32000.0,
      'quantity': 18,
      'image_url': 'https://images.unsplash.com/photo-1607478900766-efe13248b125?w=400&h=300&fit=crop',
      'available_from': '09:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Roti Sobek Keju & Coklat',
      'description': 'Roti sobek premium dengan topping keju melimpah dan coklat chip',
      'original_price': 55000.0,
      'discount_price': 28000.0,
      'quantity': 14,
      'image_url': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Puff Pastry Sosis & Tuna',
      'description': 'Paket 8-10 puff pastry: sosis keju, tuna mayo, dan ayam panggang',
      'original_price': 70000.0,
      'discount_price': 35000.0,
      'quantity': 16,
      'image_url': 'https://images.unsplash.com/photo-1619566636858-adf5b61d9c00?w=400&h=300&fit=crop',
      'available_from': '07:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 1,
      'name': 'Kue Kering Lebaran Mix',
      'description': 'Paket kue kering: nastar, kastengel, putri salju, dan choco chip cookies',
      'original_price': 90000.0,
      'discount_price': 45000.0,
      'quantity': 12,
      'image_url': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=300&fit=crop',
      'available_from': '07:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Bread & Butter - Additional Products
    await db.insert('products', {
      'bakery_id': 2,
      'name': 'Pretzel & Soft Roll Bundle',
      'description': 'Paket 6-8 pretzel Jerman dan soft roll organik dengan butter tawar',
      'original_price': 85000.0,
      'discount_price': 42000.0,
      'quantity': 13,
      'image_url': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 2,
      'name': 'Scone & English Muffin Set',
      'description': 'Paket scone blueberry, cranberry dan english muffin dengan clotted cream',
      'original_price': 95000.0,
      'discount_price': 48000.0,
      'quantity': 10,
      'image_url': 'https://images.unsplash.com/photo-1609501676725-7186f017a4b0?w=400&h=300&fit=crop',
      'available_from': '07:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 2,
      'name': 'Whole Wheat Pizza Base',
      'description': 'Paket 4 pizza base gandum utuh siap panggang dengan saus tomat organik',
      'original_price': 75000.0,
      'discount_price': 38000.0,
      'quantity': 15,
      'image_url': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=300&fit=crop',
      'available_from': '10:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 2,
      'name': 'Granola & Energy Bar Pack',
      'description': 'Paket granola organik dan 6 energy bar untuk sarapan sehat',
      'original_price': 100000.0,
      'discount_price': 50000.0,
      'quantity': 11,
      'image_url': 'https://images.unsplash.com/photo-1526318896980-cf78c088247c?w=400&h=300&fit=crop',
      'available_from': '06:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // The French Bakery - Additional Products
    await db.insert('products', {
      'bakery_id': 3,
      'name': 'Kouign-Amann & Palmier Box',
      'description': 'Paket 4-5 kouign-amann Brittany dan palmier crispy dengan butter Perancis',
      'original_price': 115000.0,
      'discount_price': 58000.0,
      'quantity': 7,
      'image_url': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 3,
      'name': 'Quiche Lorraine & Savory Tart',
      'description': 'Paket quiche lorraine, mushroom tart, dan tomato basil tart',
      'original_price': 145000.0,
      'discount_price': 72000.0,
      'quantity': 6,
      'image_url': 'https://images.unsplash.com/photo-1476124369491-c41b592e5ce7?w=400&h=300&fit=crop',
      'available_from': '11:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 3,
      'name': 'Pain de Campagne & Epi Wheat',
      'description': 'Roti kampung Perancis dan epi gandum panggang dengan herb Provence',
      'original_price': 105000.0,
      'discount_price': 52000.0,
      'quantity': 9,
      'image_url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop',
      'available_from': '07:30',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 3,
      'name': 'Religieuse & Paris-Brest',
      'description': 'Paket dessert klasik: religieuse coklat dan paris-brest praline',
      'original_price': 130000.0,
      'discount_price': 65000.0,
      'quantity': 5,
      'image_url': 'https://images.unsplash.com/photo-1519915212116-7cfef71f1d3e?w=400&h=300&fit=crop',
      'available_from': '09:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // KOPI & ROTI KITA (Bakery ID 4)
    await db.insert('products', {
      'bakery_id': 4,
      'name': 'Pisang Coklat & Kopi Bundle',
      'description': 'Paket roti pisang coklat keju + cold brew coffee untuk sarapan',
      'original_price': 55000.0,
      'discount_price': 28000.0,
      'quantity': 20,
      'image_url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop',
      'available_from': '06:30',
      'available_until': '22:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 4,
      'name': 'Martabak Mini Party Pack',
      'description': 'Paket 12 martabak mini berbagai rasa: coklat keju, green tea, red velvet',
      'original_price': 80000.0,
      'discount_price': 40000.0,
      'quantity': 15,
      'image_url': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=300&fit=crop',
      'available_from': '10:00',
      'available_until': '22:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 4,
      'name': 'Roti John Jumbo Pack',
      'description': 'Paket 4-5 roti john jumbo: beef, chicken, fish, dan veggie',
      'original_price': 90000.0,
      'discount_price': 45000.0,
      'quantity': 12,
      'image_url': 'https://images.unsplash.com/photo-1619566636858-adf5b61d9c00?w=400&h=300&fit=crop',
      'available_from': '11:00',
      'available_until': '22:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 4,
      'name': 'Onde-Onde Modern Box',
      'description': 'Paket onde-onde modern: matcha, cheese, nutella, dan original',
      'original_price': 60000.0,
      'discount_price': 30000.0,
      'quantity': 18,
      'image_url': 'https://images.unsplash.com/photo-1587241321921-91a834d82ffc?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '22:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // GOLDEN CRUST BAKEHOUSE (Bakery ID 5)
    await db.insert('products', {
      'bakery_id': 5,
      'name': 'Bolu Gulung Rainbow Pack',
      'description': 'Paket 3 bolu gulung: pandan, strawberry, dan coklat marble',
      'original_price': 75000.0,
      'discount_price': 38000.0,
      'quantity': 16,
      'image_url': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=300&fit=crop',
      'available_from': '07:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 5,
      'name': 'Cake Slice Sampler',
      'description': 'Paket 6 slice cake: red velvet, tiramisu, black forest, cheese, lemon, chocolate fudge',
      'original_price': 120000.0,
      'discount_price': 60000.0,
      'quantity': 10,
      'image_url': 'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400&h=300&fit=crop',
      'available_from': '09:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 5,
      'name': 'Cupcake Party Mix',
      'description': 'Paket 12 cupcake dekorasi cantik berbagai rasa dan topping',
      'original_price': 95000.0,
      'discount_price': 48000.0,
      'quantity': 14,
      'image_url': 'https://images.unsplash.com/photo-1607478900766-efe13248b125?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 5,
      'name': 'Kue Lapis Legit Premium',
      'description': 'Lapis legit premium 20 lapis dengan butter Belanda dan rempah pilihan',
      'original_price': 180000.0,
      'discount_price': 90000.0,
      'quantity': 8,
      'image_url': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=300&fit=crop',
      'available_from': '09:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // SUNRISE BAKERY & CAFE (Bakery ID 6)
    await db.insert('products', {
      'bakery_id': 6,
      'name': 'Sunrise Breakfast Box',
      'description': 'Paket sarapan: croissant, toast, scrambled egg sandwich, dan juice',
      'original_price': 85000.0,
      'discount_price': 43000.0,
      'quantity': 22,
      'image_url': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=400&h=300&fit=crop',
      'available_from': '05:30',
      'available_until': '11:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 6,
      'name': 'Panini & Wrap Combo',
      'description': 'Paket 4 panini dan wrap: chicken pesto, tuna melt, beef bbq, veggie supreme',
      'original_price': 100000.0,
      'discount_price': 50000.0,
      'quantity': 18,
      'image_url': 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=400&h=300&fit=crop',
      'available_from': '10:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 6,
      'name': 'Sunset Pastry Platter',
      'description': 'Paket pastry sore: apple strudel, cherry danish, almond croissant',
      'original_price': 95000.0,
      'discount_price': 48000.0,
      'quantity': 12,
      'image_url': 'https://images.unsplash.com/photo-1530610476181-d83430b64dcd?w=400&h=300&fit=crop',
      'available_from': '15:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 6,
      'name': 'Smoothie Bowl & Acai Pack',
      'description': 'Paket 3 smoothie bowl dan acai bowl dengan granola dan fresh fruit',
      'original_price': 110000.0,
      'discount_price': 55000.0,
      'quantity': 10,
      'image_url': 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&h=300&fit=crop',
      'available_from': '06:00',
      'available_until': '20:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // ARTISAN SOURDOUGH LAB (Bakery ID 7)
    await db.insert('products', {
      'bakery_id': 7,
      'name': 'Classic Sourdough Trio',
      'description': 'Paket 3 sourdough: country loaf, whole wheat, dan rye sourdough',
      'original_price': 135000.0,
      'discount_price': 68000.0,
      'quantity': 9,
      'image_url': 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 7,
      'name': 'Sourdough Specialty Bundle',
      'description': 'Paket sourdough special: olive & rosemary, walnut & fig, garlic & herb',
      'original_price': 150000.0,
      'discount_price': 75000.0,
      'quantity': 7,
      'image_url': 'https://images.unsplash.com/photo-1598373182133-52452f7691ef?w=400&h=300&fit=crop',
      'available_from': '10:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 7,
      'name': 'Sourdough Pizza Dough Set',
      'description': 'Paket 4 pizza dough sourdough siap panggang dengan starter culture',
      'original_price': 80000.0,
      'discount_price': 40000.0,
      'quantity': 13,
      'image_url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 7,
      'name': 'Fermented Bread Sampler',
      'description': 'Paket roti fermentasi: kombucha bread, kefir loaf, dan yogurt flatbread',
      'original_price': 120000.0,
      'discount_price': 60000.0,
      'quantity': 8,
      'image_url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop',
      'available_from': '08:00',
      'available_until': '19:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // SWEET MOMENTS PATISSERIE (Bakery ID 8)
    await db.insert('products', {
      'bakery_id': 8,
      'name': 'Opera Cake & Fraisier Box',
      'description': 'Paket premium: opera cake coklat dan fraisier strawberry fresh cream',
      'original_price': 165000.0,
      'discount_price': 83000.0,
      'quantity': 6,
      'image_url': 'https://images.unsplash.com/photo-1588195538326-c5b1e5b66e4b?w=400&h=300&fit=crop',
      'available_from': '09:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 8,
      'name': 'Macarons Deluxe Collection',
      'description': 'Paket 20 macaron premium: pistachio, raspberry, lemon, salted caramel, vanilla',
      'original_price': 140000.0,
      'discount_price': 70000.0,
      'quantity': 11,
      'image_url': 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=400&h=300&fit=crop',
      'available_from': '09:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 8,
      'name': 'Petit Gateaux Selection',
      'description': 'Paket 8 petit gateaux mini: chocolate fondant, lemon tart, raspberry mousse',
      'original_price': 155000.0,
      'discount_price': 78000.0,
      'quantity': 8,
      'image_url': 'https://images.unsplash.com/photo-1519915212116-7cfef71f1d3e?w=400&h=300&fit=crop',
      'available_from': '10:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'bakery_id': 8,
      'name': 'Dessert Box Premium Pack',
      'description': 'Paket 4 dessert box: tiramisu, mango sticky rice, matcha latte, red velvet',
      'original_price': 130000.0,
      'discount_price': 65000.0,
      'quantity': 14,
      'image_url': 'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400&h=300&fit=crop',
      'available_from': '09:00',
      'available_until': '21:00',
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert dummy coupons (with error handling for old database)
    try {
      final now = DateTime.now();
      await db.insert('coupons', {
        'code': 'WELCOME10',
        'title': 'Welcome Bonus',
        'description': 'Diskon 10% untuk pengguna baru',
        'discount_percentage': 10,
        'max_discount': 15000.0,
        'min_purchase': 30000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 30)).toIso8601String(),
        'max_usage': 100,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });

      await db.insert('coupons', {
        'code': 'HEMAT20',
        'title': 'Super Hemat 20%',
        'description': 'Diskon 20% untuk pembelian minimal 50rb',
        'discount_percentage': 20,
        'max_discount': 25000.0,
        'min_purchase': 50000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 7)).toIso8601String(),
        'max_usage': 50,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });

      await db.insert('coupons', {
        'code': 'FOODSAVER',
        'title': 'Food Saver Hero',
        'description': 'Diskon 15% untuk penyelamat makanan',
        'discount_percentage': 15,
        'max_discount': 20000.0,
        'min_purchase': 40000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 14)).toIso8601String(),
        'max_usage': 75,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });

      await db.insert('coupons', {
        'code': 'ROTIBAKAR10',
        'title': 'Roti Bakar 88 Special',
        'description': 'Diskon 10% khusus Roti Bakar 88',
        'discount_percentage': 10,
        'max_discount': 12000.0,
        'min_purchase': 30000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 30)).toIso8601String(),
        'max_usage': 200,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });

      await db.insert('coupons', {
        'code': 'ORGANIC15',
        'title': 'Bread & Butter Organic',
        'description': 'Diskon 15% produk organik',
        'discount_percentage': 15,
        'max_discount': 18000.0,
        'min_purchase': 40000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 21)).toIso8601String(),
        'max_usage': 150,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });

      await db.insert('coupons', {
        'code': 'FRENCH20',
        'title': 'The French Bakery Promo',
        'description': 'Diskon 20% pastry Perancis',
        'discount_percentage': 20,
        'max_discount': 22000.0,
        'min_purchase': 50000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 15)).toIso8601String(),
        'max_usage': 100,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });

      await db.insert('coupons', {
        'code': 'WEEKEND25',
        'title': 'Weekend Special',
        'description': 'Diskon 25% khusus weekend',
        'discount_percentage': 25,
        'max_discount': 30000.0,
        'min_purchase': 60000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 3)).toIso8601String(),
        'max_usage': 30,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });
    } catch (e) {
      print('Note: Could not insert coupons (table may not exist in old database): $e');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Method to completely reset database
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'safefood.db');
    
    // Close existing connection
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Delete the database file
    await deleteDatabase(path);
    
    // Reinitialize
    _database = await _initDB('safefood.db');
  }
}
