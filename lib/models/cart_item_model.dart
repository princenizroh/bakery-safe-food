class CartItem {
  final int? id;
  final int productId;
  final String productName;
  final double productPrice;
  final String? productImage;
  final int bakeryId;
  final String bakeryName;
  final int quantity;

  CartItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.productImage,
    required this.bakeryId,
    required this.bakeryName,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'product_image': productImage,
      'bakery_id': bakeryId,
      'bakery_name': bakeryName,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productPrice: map['product_price'],
      productImage: map['product_image'],
      bakeryId: map['bakery_id'],
      bakeryName: map['bakery_name'],
      quantity: map['quantity'],
    );
  }

  double get totalPrice => productPrice * quantity;
}
