import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bakery_model.dart';
import '../models/coupon_model.dart';
import '../services/bakery_service.dart';
import '../services/coupon_service.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../widgets/product_card.dart';
import '../screens/product_detail_screen.dart';
import '../services/cart_service.dart';
import '../utils/format_helper.dart';
import '../utils/colors.dart';

class BakeryDetailScreen extends StatefulWidget {
  final Bakery bakery;

  const BakeryDetailScreen({super.key, required this.bakery});

  @override
  State<BakeryDetailScreen> createState() => _BakeryDetailScreenState();
}

class _BakeryDetailScreenState extends State<BakeryDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCoupons();
  }

  Future<void> _loadProducts() async {
    final bakeryService = context.read<BakeryService>();
    await bakeryService.loadProductsByBakery(widget.bakery.id!);
  }

  Future<void> _loadCoupons() async {
    final couponService = context.read<CouponService>();
    await couponService.loadAvailableCoupons();
    
    // Insert dummy coupons if empty
    if (couponService.availableCoupons.isEmpty) {
      await _insertDummyCoupons();
      await couponService.loadAvailableCoupons();
    }
    
    await couponService.loadUserCoupons(
      context.read<AuthService>().currentUser?.id ?? 0,
    );
    setState(() {}); // Force rebuild
  }
  
  Future<void> _insertDummyCoupons() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    
    try {
      await db.insert('coupons', {
        'code': 'HEMAT20',
        'title': 'Super Hemat 20%',
        'description': 'Diskon 20% untuk semua produk',
        'discount_percentage': 20,
        'max_discount': 25000.0,
        'min_purchase': 30000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 30)).toIso8601String(),
        'max_usage': 100,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });
      
      await db.insert('coupons', {
        'code': 'WELCOME15',
        'title': 'Welcome Bonus',
        'description': 'Diskon 15% untuk pengguna baru',
        'discount_percentage': 15,
        'max_discount': 20000.0,
        'min_purchase': 25000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 60)).toIso8601String(),
        'max_usage': 200,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });
      
      await db.insert('coupons', {
        'code': 'FOODSAVER',
        'title': 'Food Saver Hero',
        'description': 'Diskon 10% selamatkan makanan',
        'discount_percentage': 10,
        'max_discount': 15000.0,
        'min_purchase': 20000.0,
        'valid_from': now.toIso8601String(),
        'valid_until': now.add(const Duration(days: 90)).toIso8601String(),
        'max_usage': 500,
        'used_count': 0,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      });
      
      print('DEBUG COUPON: Inserted 3 dummy coupons');
    } catch (e) {
      print('DEBUG COUPON: Error inserting - $e');
    }
  }

  Future<void> _claimCoupon(Coupon coupon) async {
    final authService = context.read<AuthService>();
    final couponService = context.read<CouponService>();

    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final success = await couponService.claimCoupon(
      authService.currentUser!.id!,
      coupon.id!,
    );

    if (!mounted) return;

    if (success) {
      // Dialog kupon berhasil diklaim
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
                'Kupon Berhasil Diklaim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kupon ${coupon.code} telah berhasil diklaim.\nGunakan kupon ini saat checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Dialog kupon sudah diklaim
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
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 64,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kupon Sudah Diklaim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Anda sudah mengklaim kupon ini sebelumnya.\nCek kupon Anda di halaman checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bakeryService = context.watch<BakeryService>();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                automaticallyImplyLeading: false, // Hide default back button
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.bakery.imageUrl != null
                      ? Image.network(
                          widget.bakery.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primary,
                              child: const Icon(
                                Icons.bakery_dining,
                                size: 80,
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.primary,
                          child: const Icon(
                            Icons.bakery_dining,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bakery Name
                  Text(
                    widget.bakery.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.bakery.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.bakery.distance != null) ...[
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          FormatHelper.formatDistance(widget.bakery.distance!),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (widget.bakery.description != null) ...[
                    Text(
                      widget.bakery.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Address
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(widget.bakery.address)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Phone
                  if (widget.bakery.phone != null)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 20),
                        const SizedBox(width: 8),
                        Text(widget.bakery.phone!),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Opening Hours
                  if (widget.bakery.openingTime != null &&
                      widget.bakery.closingTime != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${FormatHelper.getTimeFromString(widget.bakery.openingTime!)} - ${FormatHelper.getTimeFromString(widget.bakery.closingTime!)}',
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Coupons Section
                  _buildCouponsSection(),
                  const SizedBox(height: 24),

                  // Products Section
                  const Text(
                    'Produk Hari Ini',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Products List
          bakeryService.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : bakeryService.products.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: Text('Belum ada produk tersedia')),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = bakeryService.products[index];
                      return ProductCard(
                        product: product,
                        // onTap: buka halaman detail produk (untuk lihat info lengkap)
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                                bakery: widget.bakery,
                              ),
                            ),
                          );
                        },
                        // onOrder: tambah ke keranjang
                        onOrder: () async {
                          try {
                            final cartService = context.read<CartService>();
                            await cartService.addToCart(
                              productId: product.id!,
                              productName: product.name,
                              productPrice: product.discountPrice,
                              productImage: product.imageUrl,
                              bakeryId: widget.bakery.id!,
                              bakeryName: widget.bakery.name,
                              quantity: 1,
                            );
                            
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
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
                                          Icons.shopping_cart,
                                          size: 64,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Ditambahkan ke Keranjang',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        product.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            print('Error adding to cart: $e');
                          }
                        },
                      );
                    }, childCount: bakeryService.products.length),
                  ),
                ),
            ],
          ),
          // Floating back button yang tidak hilang saat scroll
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsSection() {
    final couponService = context.watch<CouponService>();
    final authService = context.watch<AuthService>();

    // Show ALL valid coupons (NO FILTER)
    final availableCoupons = couponService.availableCoupons
        .where((c) => c.isValid)
        .toList();

    // DEBUG: Always show section even if empty
    print('DEBUG: Available coupons count: ${availableCoupons.length}');
    print('DEBUG: All coupons: ${couponService.availableCoupons.length}');

    // Get user's claimed coupon IDs
    final claimedCouponIds =
        couponService.userCoupons.map((c) => c.id).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan Refresh button
        Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: AppColors.secondary, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Kupon Tersedia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Refresh button untuk demo - reset semua kupon
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final db = await DatabaseHelper.instance.database;
                  // Reset semua user_coupons (hapus semua claimed)
                  await db.delete('user_coupons');
                  // Reload coupons
                  await _loadCoupons();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Show placeholder if empty
        if (availableCoupons.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada kupon tersedia',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Show coupons if available
        ...availableCoupons.map((coupon) {
          final isClaimed = claimedCouponIds.contains(coupon.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isClaimed
                    ? [Colors.grey.shade200, Colors.grey.shade100]
                    : [AppColors.secondaryLight, Colors.white],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isClaimed ? Colors.grey.shade300 : AppColors.secondary,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isClaimed
                          ? Colors.grey.shade300
                          : AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isClaimed ? Icons.check_circle : Icons.local_offer_rounded,
                      color: isClaimed ? Colors.grey : AppColors.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.code,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isClaimed ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Diskon ${coupon.discountPercentage}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isClaimed
                                ? Colors.grey
                                : AppColors.secondary,
                          ),
                        ),
                        if (coupon.minPurchase > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Min. pembelian ${FormatHelper.formatCurrency(coupon.minPurchase)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isClaimed
                                  ? Colors.grey
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isClaimed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Diklaim',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: authService.currentUser != null
                            ? () => _claimCoupon(coupon)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Klaim',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
