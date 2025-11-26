import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../widgets/order_card.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authService = context.read<AuthService>();
    final orderService = context.read<OrderService>();

    if (authService.currentUser != null) {
      await orderService.loadUserOrders(authService.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderService = context.watch<OrderService>();
    final authService = context.watch<AuthService>();

    if (authService.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: orderService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderService.orders.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada pesanan',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderService.orders.length,
                itemBuilder: (context, index) {
                  final order = orderService.orders[index];
                  return OrderCard(
                    order: order,
                    onStatusChanged: _loadOrders,
                  );
                },
              ),
      ),
    );
  }
}
