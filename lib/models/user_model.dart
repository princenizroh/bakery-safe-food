class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String role; // 'customer' or 'bakery_owner'
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      role: map['role'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
