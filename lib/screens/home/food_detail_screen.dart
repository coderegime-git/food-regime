// lib/screens/home/food_detail_screen.dart
import 'package:flutter/material.dart';

class FoodDetailScreen extends StatelessWidget {
  final String foodId; const FoodDetailScreen({super.key, required this.foodId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Detail')),
      body: const Center(child: Text('Food Detail Screen')),
    );
  }
}
