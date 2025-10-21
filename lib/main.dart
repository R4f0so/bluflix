import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'app_tema.dart';
import 'perfil_provider.dart'; // ✅ ADICIONE
import 'splash.dart';
import 'options.dart';
import 'login.dart';
import 'cadastro.dart';
import 'avatar.dart';
import 'apelido.dart';
import 'catalogo.dart';
import 'adicionar_perfis.dart';
import 'avatar_filho.dart';
import 'apelido_filho.dart';
import 'mudar_perfil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase inicializado com sucesso!");

  runApp(
    MultiProvider( // ✅ MUDANÇA: Múltiplos providers
      providers: [
        ChangeNotifierProvider(create: (_) => AppTema()),
        ChangeNotifierProvider(create: (_) => PerfilProvider()), // ✅ NOVO
      ],
      child: const BluFlixApp(),
    ),
  );
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
        GoRoute(
          path: '/catalogo',
          builder: (context, state) => const CatalogoScreen(),
        ),
        GoRoute(
          path: '/adicionar-perfis',
          builder: (context, state) => const AdicionarPerfisScreen(),
        ),
        GoRoute(
          path: '/avatar-filho',
          builder: (context, state) => const AvatarFilhoScreen(),
        ),
        GoRoute(
          path: '/apelido-filho',
          builder: (context, state) {
            final avatar = state.extra as String?;
            return ApelidoFilhoScreen(
              selectedAvatar: avatar ?? 'assets/avatar1.png',
            );
          },
        ),
        GoRoute(
          path: '/mudar-perfil',
          builder: (context, state) => const MudarPerfilScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
