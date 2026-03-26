// lib/screens/home/category_foods_screen.dart
import 'package:flutter/material.dart';

class CategoryFoodsScreen extends StatelessWidget {
  final String categoryId; const CategoryFoodsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category')),
      body: const Center(child: Text('Category Screen')),
    );
  }
}
