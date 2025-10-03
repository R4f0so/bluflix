import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // gerado pelo FlutterFire CLI

import 'splash.dart';
import 'options.dart';
import 'login.dart';
import 'cadastro.dart';
import 'avatar.dart';
import 'apelido.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções do arquivo firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase inicializado com sucesso!");
  runApp(const BluFlixApp());
}

class BluFlixApp extends StatelessWidget {
  const BluFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/options',
          builder: (context, state) => const OptionsScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/cadastro',
          builder: (context, state) => const CadastroScreen(),
        ),
        GoRoute(
          path: '/avatar',
          builder: (context, state) => const AvatarScreen(),
        ),
        GoRoute(
          path: '/apelido',
          builder: (context, state) {
            final avatar = state.extra as String?;
            return ApelidoScreen(
              selectedAvatar: avatar ?? 'assets/avatar1.png',
            );
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
