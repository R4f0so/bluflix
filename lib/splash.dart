import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // Timer de 10 segundos para ir para a tela de opções
    Timer(const Duration(seconds: 8), () {
      if (mounted) {
        context.go('/options');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/morning_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.5, end: 1.5),
            duration: const Duration(seconds: 10), // mesma duração do Timer
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Image.asset("assets/logo.png", width: 200),
          ),
        ),
      ),
    );
  }
}
