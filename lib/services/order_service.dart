import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';

class OrderService extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<bool> createOrder({
    required int userId,
    required int bakeryId,
    required int productId,
    required int quantity,
    required double totalPrice,
    String? pickupTime,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;

      final order = Order(
        userId: userId,
        bakeryId: bakeryId,
        productId: productId,
        quantity: quantity,
        totalPrice: totalPrice,
        status: 'pending',
        pickupTime: pickupTime,
        orderDate: DateTime.now(),
      );

      await db.insert('orders', order.toMap());

      // Update product quantity
      await db.rawUpdate(
        'UPDATE products SET quantity = quantity - ? WHERE id = ?',
        [quantity, productId],
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserOrders(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'orders',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'order_date DESC',
      );

      _orders = result.map((map) => Order.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'orders',
        {'status': status},
        where: 'id = ?',
        whereArgs: [orderId],
      );
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
