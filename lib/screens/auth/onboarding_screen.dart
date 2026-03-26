// lib/screens/auth/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import '../../constants/constants.dart';
import '../../routes/app_routes.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body:  Center(child: GestureDetector(

          onTap: (){
            context.go(AppRoutes.login);

          },
          child:const Text('Onboarding Screen'))),
    );
  }
}
