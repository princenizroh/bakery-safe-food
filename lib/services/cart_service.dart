import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/cart_item_model.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  /// Load semua item di cart
  Future<void> loadCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;
      final result = await db.query('cart', orderBy: 'id DESC');

      _cartItems = result.map((map) => CartItem.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading cart: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add product ke cart
  Future<bool> addToCart({
    required int productId,
    required String productName,
    required double productPrice,
    String? productImage,
    required int bakeryId,
    required String bakeryName,
    required int quantity,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Check if product already in cart
      final existing = await db.query(
        'cart',
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      if (existing.isNotEmpty) {
        // Update quantity
        final existingItem = CartItem.fromMap(existing.first);
        final newQuantity = existingItem.quantity + quantity;
        
        await db.update(
          'cart',
          {'quantity': newQuantity},
          where: 'id = ?',
          whereArgs: [existingItem.id],
        );
      } else {
        // Insert new
        await db.insert('cart', {
          'product_id': productId,
          'product_name': productName,
          'product_price': productPrice,
          'product_image': productImage,
          'bakery_id': bakeryId,
          'bakery_name': bakeryName,
          'quantity': quantity,
        });
      }

      await loadCart();
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  /// Update quantity item di cart
  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
      } else {
        await db.update(
          'cart',
          {'quantity': newQuantity},
          where: 'id = ?',
          whereArgs: [cartItemId],
        );
        await loadCart();
      }
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  /// Remove item dari cart
  Future<void> removeFromCart(int cartItemId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('cart', where: 'id = ?', whereArgs: [cartItemId]);
      await loadCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  /// Clear semua cart
  Future<void> clearCart() async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('cart');
      await loadCart();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}
