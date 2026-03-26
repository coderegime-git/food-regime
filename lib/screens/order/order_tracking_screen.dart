// lib/screens/order/order_tracking_screen.dart
import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId; const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: const Center(child: Text('Track Order Screen')),
    );
  }
}
