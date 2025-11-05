import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/core/routes/app_routes.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase inicializado com sucesso!");

  runApp(const BluFlixApp());
}

class BluFlixApp extends StatelessWidget {
  const BluFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTema()),
        ChangeNotifierProvider(create: (_) => PerfilProvider()),
      ],
      child: Consumer<AppTema>(
        builder: (context, appTema, _) {
          return MaterialApp.router(
            title: 'BluFlix',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: appTema.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              scaffoldBackgroundColor: appTema.backgroundColor,
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: appTema.textColor),
                bodyMedium: TextStyle(color: appTema.textColor),
              ),
            ),
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
