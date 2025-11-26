class Order {
  final int? id;
  final int userId;
  final int bakeryId;
  final int productId;
  final int quantity;
  final double totalPrice;
  final String
  status; // 'pending', 'confirmed', 'ready', 'completed', 'cancelled'
  final String? pickupTime;
  final DateTime orderDate;

  Order({
    this.id,
    required this.userId,
    required this.bakeryId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    this.pickupTime,
    required this.orderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'bakery_id': bakeryId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
      'pickup_time': pickupTime,
      'order_date': orderDate.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['user_id'],
      bakeryId: map['bakery_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      totalPrice: map['total_price']?.toDouble() ?? 0.0,
      status: map['status'],
      pickupTime: map['pickup_time'],
      orderDate: DateTime.parse(map['order_date']),
    );
  }
}
