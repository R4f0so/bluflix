import 'package:flutter/material.dart';
import 'dart:async'; // pra usar o Timer
import 'options.dart'; // importar a tela de login
import 'avatar.dart';

void main() {
  runApp(const BluFlixApp());
}

class BluFlixApp extends StatelessWidget {
  const BluFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: const SplashScreen(),
      home: const AvatarScreen(),
    );
  }
}

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

    // Timer de 10 segundos para ir para a tela de login
    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OptionsScreen()),
      );
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
            tween: Tween<double>(
              begin: 0.5,
              end: 1.5,
            ), // escala inicial -> final
            duration: const Duration(seconds: 10), // mesma duração da Splash
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
