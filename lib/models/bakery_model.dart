class Bakery {
  final int? id;
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? imageUrl;
  final double rating;
  final String? openingTime;
  final String? closingTime;
  final int? userId;
  final DateTime createdAt;

  // For distance calculation
  double? distance;

  Bakery({
    this.id,
    required this.name,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.imageUrl,
    this.rating = 0.0,
    this.openingTime,
    this.closingTime,
    this.userId,
    required this.createdAt,
    this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'image_url': imageUrl,
      'rating': rating,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bakery.fromMap(Map<String, dynamic> map) {
    return Bakery(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      phone: map['phone'],
      imageUrl: map['image_url'],
      rating: map['rating']?.toDouble() ?? 0.0,
      openingTime: map['opening_time'],
      closingTime: map['closing_time'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Bakery copyWith({double? distance}) {
    return Bakery(
      id: id,
      name: name,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      imageUrl: imageUrl,
      rating: rating,
      openingTime: openingTime,
      closingTime: closingTime,
      userId: userId,
      createdAt: createdAt,
      distance: distance ?? this.distance,
    );
  }
}
