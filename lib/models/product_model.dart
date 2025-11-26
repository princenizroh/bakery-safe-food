class Product {
  final int? id;
  final int bakeryId;
  final String name;
  final String? description;
  final double originalPrice;
  final double discountPrice;
  final int quantity;
  final String? imageUrl;
  final String? availableFrom;
  final String? availableUntil;
  final bool isAvailable;
  final DateTime createdAt;

  Product({
    this.id,
    required this.bakeryId,
    required this.name,
    this.description,
    required this.originalPrice,
    required this.discountPrice,
    required this.quantity,
    this.imageUrl,
    this.availableFrom,
    this.availableUntil,
    this.isAvailable = true,
    required this.createdAt,
  });

  double get discountPercentage {
    return ((originalPrice - discountPrice) / originalPrice * 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bakery_id': bakeryId,
      'name': name,
      'description': description,
      'original_price': originalPrice,
      'discount_price': discountPrice,
      'quantity': quantity,
      'image_url': imageUrl,
      'available_from': availableFrom,
      'available_until': availableUntil,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      bakeryId: map['bakery_id'],
      name: map['name'],
      description: map['description'],
      originalPrice: map['original_price']?.toDouble() ?? 0.0,
      discountPrice: map['discount_price']?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 0,
      imageUrl: map['image_url'],
      availableFrom: map['available_from'],
      availableUntil: map['available_until'],
      isAvailable: map['is_available'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
