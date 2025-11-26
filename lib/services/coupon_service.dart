import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/coupon_model.dart';

class CouponService extends ChangeNotifier {
  List<Coupon> _availableCoupons = [];
  List<Coupon> _userCoupons = [];
  bool _isLoading = false;

  List<Coupon> get availableCoupons => _availableCoupons;
  List<Coupon> get userCoupons => _userCoupons;
  bool get isLoading => _isLoading;

  Future<void> loadAvailableCoupons() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;
      print('DEBUG COUPON: Loading coupons from database...');
      
      final result = await db.query(
        'coupons',
        where: 'is_active = 1',
        orderBy: 'discount_percentage DESC',
      );

      print('DEBUG COUPON: Found ${result.length} active coupons');
      _availableCoupons = result.map((map) => Coupon.fromMap(map)).toList();

      // Filter only valid coupons
      _availableCoupons = _availableCoupons.where((c) => c.isValid).toList();
      print('DEBUG COUPON: ${_availableCoupons.length} valid coupons after filter');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('DEBUG COUPON ERROR: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserCoupons(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;

      // Get user's claimed coupons
      final result = await db.rawQuery('''
        SELECT c.* FROM coupons c
        INNER JOIN user_coupons uc ON c.id = uc.coupon_id
        WHERE uc.user_id = ? AND uc.is_used = 0 AND c.is_active = 1
      ''', [userId]);

      _userCoupons = result.map((map) => Coupon.fromMap(map)).toList();

      // Filter only valid coupons
      _userCoupons = _userCoupons.where((c) => c.isValid).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> claimCoupon(int userId, int couponId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Check if user already claimed this coupon
      final existing = await db.query(
        'user_coupons',
        where: 'user_id = ? AND coupon_id = ?',
        whereArgs: [userId, couponId],
      );

      if (existing.isNotEmpty) {
        return false; // Already claimed
      }

      // Claim the coupon
      await db.insert('user_coupons', {
        'user_id': userId,
        'coupon_id': couponId,
        'claimed_at': DateTime.now().toIso8601String(),
        'is_used': 0,
      });

      await loadUserCoupons(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> useCoupon(int userId, int couponId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // HAPUS record dari user_coupons setelah dipakai
      await db.delete(
        'user_coupons',
        where: 'user_id = ? AND coupon_id = ? AND is_used = 0',
        whereArgs: [userId, couponId],
      );

      // Increment used_count in coupons table
      await db.rawUpdate('''
        UPDATE coupons 
        SET used_count = used_count + 1 
        WHERE id = ?
      ''', [couponId]);

      await loadUserCoupons(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Coupon? findCouponByCode(String code) {
    try {
      return _userCoupons.firstWhere(
        (coupon) =>
            coupon.code.toUpperCase() == code.toUpperCase() && coupon.isValid,
      );
    } catch (e) {
      return null;
    }
  }
}
