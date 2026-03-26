// lib/screens/order/order_confirmation_screen.dart
import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId; const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmed')),
      body: const Center(child: Text('Order Confirmed Screen')),
    );
  }
}
