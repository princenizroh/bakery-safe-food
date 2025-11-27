import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/coupon_service.dart';
import '../models/coupon_model.dart';
import '../database/database_helper.dart';
import '../utils/format_helper.dart';
import '../utils/colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    await context.read<CartService>().loadCart();
  }

  Future<void> _checkoutAllItems(
    BuildContext context,
    CartService cartService,
  ) async {
    // Show checkout bottom sheet untuk SEMUA items sekaligus
    final result = await _showCartCheckoutBottomSheet(
      context,
      cartService,
    );

    // Kalau berhasil checkout (user tidak cancel), clear cart
    if (result == true) {
      await cartService.clearCart();
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pesanan Berhasil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Berhasil checkout ${cartService.totalItems} produk',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<bool?> _showCartCheckoutBottomSheet(
    BuildContext context,
    CartService cartService,
  ) async {
    TimeOfDay? pickupTime;
    String paymentMethod = 'cod';
    Coupon? selectedCoupon;

    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Konfirmasi Pesanan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(bottomSheetContext, false),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Items List
                        const Text(
                          'Produk yang Dipesan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...cartService.cartItems.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              if (item.productImage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.productImage!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: AppColors.primaryLight,
                                      child: const Icon(Icons.card_giftcard, size: 24),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      item.bakeryName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    FormatHelper.formatCurrency(item.totalPrice),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),

                        const SizedBox(height: 24),

                        // Pickup Time
                        const Text(
                          'Jam Pengambilan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setModalState(() {
                                pickupTime = time;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text(
                                  pickupTime != null
                                      ? '${pickupTime!.hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Pilih jam pengambilan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: pickupTime != null
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Coupon Section
                        const Text(
                          'Kupon Diskon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final couponService = context.read<CouponService>();
                            final authService = context.read<AuthService>();
                            
                            if (authService.currentUser != null) {
                              await couponService.loadUserCoupons(authService.currentUser!.id!);
                              
                              if (couponService.userCoupons.isNotEmpty && context.mounted) {
                                final selected = await showModalBottomSheet<Coupon>(
                                  context: context,
                                  builder: (modalContext) => Container(
                                    height: 400,
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Pilih Kupon',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: couponService.userCoupons.length,
                                            itemBuilder: (context, index) {
                                              final coupon = couponService.userCoupons[index];
                                              final canUse = cartService.totalPrice >= coupon.minPurchase;
                                              
                                              Widget trailing;
                                              if (canUse) {
                                                trailing = const Icon(Icons.chevron_right);
                                              } else {
                                                trailing = Text(
                                                  'Min tidak tercapai',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red.shade700,
                                                  ),
                                                );
                                              }
                                              
                                              return Card(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                child: ListTile(
                                                  leading: const Icon(Icons.local_offer, color: AppColors.primary),
                                                  title: Text(coupon.title),
                                                  subtitle: Text(
                                                    '${coupon.discountPercentage}% off (min ${FormatHelper.formatCurrency(coupon.minPurchase)})',
                                                  ),
                                                  trailing: trailing,
                                                  enabled: canUse,
                                                  onTap: canUse
                                                      ? () {
                                                          Navigator.pop(modalContext, coupon);
                                                        }
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                
                                if (selected != null) {
                                  setModalState(() {
                                    selectedCoupon = selected;
                                  });
                                }
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedCoupon != null
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  color: selectedCoupon != null
                                      ? AppColors.primary
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedCoupon != null
                                        ? '${selectedCoupon!.title} (-${selectedCoupon!.discountPercentage}%)'
                                        : 'Pilih kupon (opsional)',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: selectedCoupon != null
                                          ? Colors.black
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                if (selectedCoupon != null)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () {
                                      setModalState(() {
                                        selectedCoupon = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Payment Method
                        const Text(
                          'Metode Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RadioListTile<String>(
                          title: const Text('Cash on Delivery (COD)'),
                          subtitle: const Text('Bayar saat pengambilan'),
                          value: 'cod',
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            setModalState(() {
                              paymentMethod = value!;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: const Text('Transfer Bank'),
                          subtitle: const Text('Transfer sebelum pengambilan'),
                          value: 'transfer',
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            setModalState(() {
                              paymentMethod = value!;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show discount if coupon selected
                        if (selectedCoupon != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                FormatHelper.formatCurrency(cartService.totalPrice),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Diskon (${selectedCoupon!.title})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                '- ${FormatHelper.formatCurrency(selectedCoupon!.calculateDiscount(cartService.totalPrice))}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total (${cartService.totalItems} item)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FormatHelper.formatCurrency(
                                    selectedCoupon != null
                                        ? cartService.totalPrice - selectedCoupon!.calculateDiscount(cartService.totalPrice)
                                        : cartService.totalPrice,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: pickupTime != null
                                ? () async {
                                    // Process all orders
                                    final authService = context.read<AuthService>();
                                    
                                    if (authService.currentUser == null) {
                                      Navigator.pop(bottomSheetContext, false);
                                      return;
                                    }

                                    final pickupTimeStr =
                                        '${pickupTime!.hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')}';

                                    // Calculate final price with discount
                                    final discount = selectedCoupon != null
                                        ? selectedCoupon!.calculateDiscount(cartService.totalPrice)
                                        : 0.0;
                                    final finalPrice = cartService.totalPrice - discount;
                                    
                                    // Create 1 order for all items
                                    final db = await DatabaseHelper.instance.database;
                                    
                                    try {
                                      // CRITICAL: Check if columns exist, add if missing
                                      final columns = await db.rawQuery('PRAGMA table_info(orders)');
                                      final columnNames = columns.map((col) => col['name'] as String).toList();
                                      
                                      if (!columnNames.contains('payment_method')) {
                                        print('⚠️ payment_method column missing, adding...');
                                        await db.execute('ALTER TABLE orders ADD COLUMN payment_method TEXT DEFAULT \'cod\'');
                                        print('✅ Added payment_method column');
                                      }
                                      
                                      if (!columnNames.contains('coupon_id')) {
                                        print('⚠️ coupon_id column missing, adding...');
                                        await db.execute('ALTER TABLE orders ADD COLUMN coupon_id INTEGER');
                                        print('✅ Added coupon_id column');
                                      }
                                      
                                      if (!columnNames.contains('discount_amount')) {
                                        print('⚠️ discount_amount column missing, adding...');
                                        await db.execute('ALTER TABLE orders ADD COLUMN discount_amount REAL DEFAULT 0');
                                        print('✅ Added discount_amount column');
                                      }
                                      
                                      // Check if order_items table exists
                                      final tables = await db.rawQuery(
                                        "SELECT name FROM sqlite_master WHERE type='table' AND name='order_items'"
                                      );
                                      if (tables.isEmpty) {
                                        print('⚠️ order_items table missing, creating...');
                                        await db.execute('''
                                          CREATE TABLE order_items (
                                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                                            order_id INTEGER NOT NULL,
                                            product_id INTEGER NOT NULL,
                                            product_name TEXT NOT NULL,
                                            product_price REAL NOT NULL,
                                            product_image TEXT,
                                            bakery_id INTEGER NOT NULL,
                                            bakery_name TEXT NOT NULL,
                                            quantity INTEGER NOT NULL,
                                            subtotal REAL NOT NULL,
                                            FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
                                          )
                                        ''');
                                        print('✅ Created order_items table');
                                      }
                                      
                                      // Insert order header
                                      final orderId = await db.insert('orders', {
                                        'user_id': authService.currentUser!.id!,
                                        'bakery_id': cartService.cartItems.first.bakeryId,
                                        'product_id': 0, // Not used for cart orders
                                        'quantity': cartService.totalItems,
                                        'total_price': finalPrice,
                                        'status': 'pending',
                                        'pickup_time': pickupTimeStr,
                                        'order_date': DateTime.now().toIso8601String(),
                                        'payment_method': paymentMethod,
                                        'coupon_id': selectedCoupon?.id,
                                        'discount_amount': discount,
                                      });
                                      
                                      // Insert order items
                                      for (var item in cartService.cartItems) {
                                        await db.insert('order_items', {
                                          'order_id': orderId,
                                          'product_id': item.productId,
                                          'product_name': item.productName,
                                          'product_price': item.productPrice,
                                          'product_image': item.productImage,
                                          'bakery_id': item.bakeryId,
                                          'bakery_name': item.bakeryName,
                                          'quantity': item.quantity,
                                          'subtotal': item.totalPrice,
                                        });
                                      }
                                      
                                      print('✅ Created order #$orderId with ${cartService.cartItems.length} items');
                                      Navigator.pop(bottomSheetContext, true);
                                      
                                    } catch (e) {
                                      print('❌ Error creating order: $e');
                                      Navigator.pop(bottomSheetContext, false);
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Konfirmasi Pesanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartService>();
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          if (cartService.cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Semua'),
                    content: const Text('Hapus semua produk dari keranjang?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await cartService.clearCart();
                }
              },
            ),
        ],
      ),
      body: cartService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartService.cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 100,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Keranjang Kosong',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan produk ke keranjang',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartService.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartService.cartItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.productImage != null
                                        ? Image.network(
                                            item.productImage!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 80,
                                              height: 80,
                                              color: AppColors.primaryLight,
                                              child: const Icon(Icons.card_giftcard),
                                            ),
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: AppColors.primaryLight,
                                            child: const Icon(Icons.card_giftcard),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.bakeryName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          FormatHelper.formatCurrency(item.productPrice),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Quantity Controls
                                  Column(
                                    children: [
                                      // Delete button
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: AppColors.error,
                                        onPressed: () async {
                                          await cartService.removeFromCart(item.id!);
                                        },
                                      ),
                                      
                                      // Quantity
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 18),
                                              onPressed: item.quantity > 1
                                                  ? () async {
                                                      await cartService.updateQuantity(
                                                        item.id!,
                                                        item.quantity - 1,
                                                      );
                                                    }
                                                  : null,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 18),
                                              onPressed: () async {
                                                await cartService.updateQuantity(
                                                  item.id!,
                                                  item.quantity + 1,
                                                );
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Bottom Bar - Total & Checkout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total (${cartService.totalItems} item)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      FormatHelper.formatCurrency(cartService.totalPrice),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: authService.currentUser != null
                                      ? () async {
                                          // Checkout each item using OrderConfirmationBottomSheet (with coupons!)
                                          await _checkoutAllItems(context, cartService);
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Checkout',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
