import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/bakery_service.dart';
import 'services/order_service.dart';
import 'services/coupon_service.dart';
import 'services/cart_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/bakery_detail_screen.dart';
import 'screens/order_confirm_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/coupons_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/saved_addresses_screen.dart';
import 'screens/cart_screen.dart';
import 'models/bakery_model.dart';
import 'models/product_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  // Initialize database and ensure coupon tables exist
  try {
    final db = await DatabaseHelper.instance.database;
    
    // Check if coupons table exists, create if not
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='coupons'"
    );
    
    if (tables.isEmpty) {
      print('🔧 Creating coupons table...');
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
      
      print('✅ Coupon tables created');
    } else {
      print('✅ Coupon tables already exist');
    }
    
    // Update bakery coordinates to actual GPS location
    print('📍 Updating bakery coordinates...');
    await db.update('bakeries', 
      {'latitude': -1.1453847, 'longitude': 116.8799866, 'address': 'Jl. MT Haryono No. 123, Balikpapan'},
      where: 'id = ?', whereArgs: [1]
    );
    await db.update('bakeries',
      {'latitude': -1.1420000, 'longitude': 116.8820000, 'address': 'Jl. Gatot Subroto No. 45, Balikpapan'},
      where: 'id = ?', whereArgs: [2]
    );
    await db.update('bakeries',
      {'latitude': -1.1480000, 'longitude': 116.8780000, 'address': 'Jl. Soekarno Hatta No. 78, Balikpapan'},
      where: 'id = ?', whereArgs: [3]
    );
    print('✅ Bakery coordinates updated');
  } catch (e) {
    print('❌ Database setup error: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BakeryService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => CouponService()),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthService>().initializeAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Show loading while initializing
        if (!authService.isInitialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.bakery_dining,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'SafeFood',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: authService.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.login:
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case AppRoutes.register:
                  return MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  );
                case AppRoutes.home:
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case AppRoutes.bakeryDetail:
                  final bakery = settings.arguments as Bakery;
                  return MaterialPageRoute(
                    builder: (_) => BakeryDetailScreen(bakery: bakery),
                  );
                case AppRoutes.orderConfirm:
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => OrderConfirmScreen(
                      product: args['product'] as Product,
                      bakery: args['bakery'] as Bakery,
                    ),
                  );
                case AppRoutes.profile:
                  return MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  );
                case AppRoutes.coupons:
                  return MaterialPageRoute(
                    builder: (_) => const CouponsScreen(),
                  );
                case '/edit-profile':
                  return MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  );
                case '/saved-addresses':
                  return MaterialPageRoute(
                    builder: (_) => const SavedAddressesScreen(),
                  );
                case '/cart':
                  return MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  );
                default:
                  return null;
              }
            },
          );
      },
    );
  }
}
