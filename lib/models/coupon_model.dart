class Coupon {
  final int? id;
  final String code;
  final String title;
  final String description;
  final int discountPercentage;
  final double? maxDiscount;
  final double minPurchase;
  final DateTime validFrom;
  final DateTime validUntil;
  final int maxUsage;
  final int usedCount;
  final bool isActive;

  Coupon({
    this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercentage,
    this.maxDiscount,
    required this.minPurchase,
    required this.validFrom,
    required this.validUntil,
    required this.maxUsage,
    this.usedCount = 0,
    this.isActive = true,
  });

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(validFrom) &&
        now.isBefore(validUntil) &&
        usedCount < maxUsage;
  }

  double calculateDiscount(double amount) {
    if (!isValid || amount < minPurchase) return 0;
    final discount = amount * (discountPercentage / 100);
    if (maxDiscount != null && discount > maxDiscount!) {
      return maxDiscount!;
    }
    return discount;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'discount_percentage': discountPercentage,
      'max_discount': maxDiscount,
      'min_purchase': minPurchase,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'max_usage': maxUsage,
      'used_count': usedCount,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'],
      code: map['code'],
      title: map['title'],
      description: map['description'],
      discountPercentage: map['discount_percentage'],
      maxDiscount: map['max_discount']?.toDouble(),
      minPurchase: map['min_purchase']?.toDouble() ?? 0.0,
      validFrom: DateTime.parse(map['valid_from']),
      validUntil: DateTime.parse(map['valid_until']),
      maxUsage: map['max_usage'],
      usedCount: map['used_count'] ?? 0,
      isActive: map['is_active'] == 1,
    );
  }
}

class UserCoupon {
  final int? id;
  final int userId;
  final int couponId;
  final DateTime claimedAt;
  final bool isUsed;
  final DateTime? usedAt;

  UserCoupon({
    this.id,
    required this.userId,
    required this.couponId,
    required this.claimedAt,
    this.isUsed = false,
    this.usedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'coupon_id': couponId,
      'claimed_at': claimedAt.toIso8601String(),
      'is_used': isUsed ? 1 : 0,
      'used_at': usedAt?.toIso8601String(),
    };
  }

  factory UserCoupon.fromMap(Map<String, dynamic> map) {
    return UserCoupon(
      id: map['id'],
      userId: map['user_id'],
      couponId: map['coupon_id'],
      claimedAt: DateTime.parse(map['claimed_at']),
      isUsed: map['is_used'] == 1,
      usedAt: map['used_at'] != null ? DateTime.parse(map['used_at']) : null,
    );
  }
}
