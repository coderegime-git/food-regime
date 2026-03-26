// lib/screens/error_screen.dart
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final Exception? error; const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Something went wrong')),
      body: const Center(child: Text('Something went wrong Screen')),
    );
  }
}
