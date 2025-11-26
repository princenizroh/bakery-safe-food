import 'package:flutter/material.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String type; // 'ewallet', 'bank', 'cod', 'credit_card'
  final IconData icon;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.isActive = true,
  });

  static List<PaymentMethod> getAvailableMethods() {
    return [
      PaymentMethod(
        id: 'cod',
        name: 'Cash on Delivery',
        type: 'cod',
        icon: Icons.money,
      ),
      PaymentMethod(
        id: 'gopay',
        name: 'GoPay',
        type: 'ewallet',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethod(
        id: 'ovo',
        name: 'OVO',
        type: 'ewallet',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethod(
        id: 'dana',
        name: 'DANA',
        type: 'ewallet',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethod(
        id: 'shopeepay',
        name: 'ShopeePay',
        type: 'ewallet',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethod(
        id: 'bca',
        name: 'BCA Virtual Account',
        type: 'bank',
        icon: Icons.account_balance,
      ),
      PaymentMethod(
        id: 'mandiri',
        name: 'Mandiri Virtual Account',
        type: 'bank',
        icon: Icons.account_balance,
      ),
      PaymentMethod(
        id: 'bni',
        name: 'BNI Virtual Account',
        type: 'bank',
        icon: Icons.account_balance,
      ),
      PaymentMethod(
        id: 'credit_card',
        name: 'Credit/Debit Card',
        type: 'credit_card',
        icon: Icons.credit_card,
      ),
    ];
  }
}
