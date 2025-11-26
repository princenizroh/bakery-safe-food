import 'package:flutter/material.dart';
import '../models/bakery_model.dart';
import '../models/product_model.dart';
import '../utils/colors.dart';
import '../utils/format_helper.dart';
import '../widgets/order_confirmation_bottom_sheet.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Bakery bakery;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.bakery,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final discountPercent = ((widget.product.originalPrice -
                widget.product.discountPrice) /
            widget.product.originalPrice *
            100)
        .round();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Product Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.product.imageUrl != null
                      ? Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryLight,
                                    AppColors.accentLight,
                                    AppColors.secondaryLight,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.bakery_dining_rounded,
                                size: 120,
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryLight,
                                AppColors.accentLight,
                                AppColors.secondaryLight,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.bakery_dining_rounded,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                  // Discount Badge
                  if (discountPercent > 0)
                    Positioned(
                      top: 60,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.error, Colors.redAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$discountPercent% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bakery Name
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.store_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.bakery.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.bakery.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Price Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.accent.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Harga Normal',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    FormatHelper.formatCurrency(
                                      widget.product.originalPrice,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 2,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0),
                                      AppColors.primary.withValues(alpha: 0.3),
                                      AppColors.primary.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Harga Hemat',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    FormatHelper.formatCurrency(
                                      widget.product.discountPrice,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stock Info
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: widget.product.quantity > 5
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.product.quantity > 5
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.product.quantity > 5
                                    ? Icons.inventory_2_rounded
                                    : Icons.warning_amber_rounded,
                                color: widget.product.quantity > 5
                                    ? AppColors.success
                                    : AppColors.warning,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.product.quantity > 5
                                    ? 'Stok tersedia: ${widget.product.quantity} paket'
                                    : 'Stok terbatas: ${widget.product.quantity} paket',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: widget.product.quantity > 5
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Description Section
                        const Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Deskripsi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.product.description ??
                                'Surprise package berisi berbagai macam roti dan kue segar dari ${widget.bakery.name}. Produk berkualitas dengan harga hemat untuk mengurangi food waste.',
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Space for button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Widget _buildIncludedItem(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 10),
  //     child: Row(
  //       children: [
  //         const Icon(
  //           Icons.check_circle_rounded,
  //           color: AppColors.secondary,
  //           size: 20,
  //         ),
  //         const SizedBox(width: 10),
  //         Text(
  //           text,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector - ICON KECIL SEJAJAR
            Container(
              height: 80,
              constraints: const BoxConstraints(minWidth: 130),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TOMBOL MINUS - ICON KECIL
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.remove,
                          size: 14, // DIKECILKAN dari 16
                          color: _quantity > 1
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  // ANGKA QUANTITY
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 14, // DIKECILKAN dari 16
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // TOMBOL PLUS - ICON KECIL
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _quantity < widget.product.quantity
                          ? () {
                              setState(() {
                                _quantity++;
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.add,
                          size: 14, // DIKECILKAN dari 16
                          color: _quantity < widget.product.quantity
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Price + Button - HARGA DI TENGAH
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HARGA DI TENGAH - SEJAJAR DENGAN +/-
                  Container(
                    height: 40,
                    alignment: Alignment.center, // PAKSA KE TENGAH
                    child: Text(
                      FormatHelper.formatCurrency(widget.product.discountPrice * _quantity),
                      style: const TextStyle(
                        fontSize: 18, // LEBIH BESAR BIAR JELAS
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center, // PAKSA CENTER
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Button SEJAJAR dengan text quantity
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        print('🛒 Order button pressed!');
                        try {
                          await OrderConfirmationBottomSheet.show(
                            context,
                            product: widget.product,
                            bakery: widget.bakery,
                          );
                          print('✅ Modal returned');
                        } catch (e) {
                          print('❌ Modal error: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pesan Sekarang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
