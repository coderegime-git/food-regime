// lib/screens/auth/otp_screen.dart
import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  final String phone; const OtpScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: const Center(child: Text('OTP Verification Screen')),
    );
  }
}
