import 'package:bluflix/admin_gerenciar_videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';
import 'package:bluflix/presentation/screens/perfil/mudar_avatar_screen.dart';
import 'package:bluflix/presentation/screens/auth/splash_screen.dart';
import 'package:bluflix/presentation/screens/auth/options_screen.dart';
import 'package:bluflix/presentation/screens/auth/login_screen.dart';
import 'package:bluflix/presentation/screens/auth/cadastro_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/avatar_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/apelido_screen.dart';
import 'package:bluflix/presentation/screens/catalogo/catalogo_screen.dart';
import 'package:bluflix/presentation/screens/perfil/adicionar_perfis_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/avatar_filho_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/apelido_filho_screen.dart';
import 'package:bluflix/presentation/screens/perfil/mudar_perfil_screen.dart';
import 'package:bluflix/presentation/screens/perfil/gerenciamento_pais_screen.dart';
import 'package:bluflix/presentation/screens/configuracoes/perfil_configs_screen.dart';
import 'package:bluflix/presentation/screens/configuracoes/perfilpai_configs_screen.dart';
import 'package:bluflix/presentation/screens/configuracoes/seguranca_config_screen.dart';
import 'package:bluflix/presentation/screens/configuracoes/tema_config_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/criapin_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/preferencias_filho_screen.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';
import 'package:bluflix/presentation/screens/catalogo/lista_videos_screen_youtube.dart';
import 'package:bluflix/presentation/screens/catalogo/video_player_youtube_screen.dart';
import 'package:bluflix/presentation/screens/admin/admin_add_video_screen.dart';
import 'package:bluflix/presentation/screens/admin/admin_listar_videos_screen.dart';
import 'package:bluflix/presentation/screens/perfil/editar_perfil_filho_screen.dart';

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
          path: '/preferencias-filho',
          builder: (context, state) {
            final extra = state.extra as Map<String, String>;
            return PreferenciasFilhoScreen(
              apelido: extra['apelido']!,
              avatar: extra['avatar']!,
            );
          },
        ),
        GoRoute(
          path: '/cadastro',
          builder: (context, state) => const CadastroScreen(),
        ),
        GoRoute(
          path: '/criapin',
          builder: (context, state) {
            final extra = state.extra as Map<String, String>;
            return CriaPinScreen(
              apelido: extra['apelido']!,
              avatar: extra['avatar']!,
            );
          },
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
              selectedAvatar: avatar ?? 'assets/avatar_crianca1.png',
            );
          },
        ),
        GoRoute(
          path: '/mudar-perfil',
          builder: (context, state) => const MudarPerfilScreen(),
        ),
        GoRoute(
          path: '/gerenciamento-pais',
          builder: (context, state) => const GerenciamentoPaisScreen(),
        ),
        GoRoute(
          path: '/perfil-configs',
          builder: (context, state) => const PerfilConfigsScreen(),
        ),
        GoRoute(
          path: '/perfilpai-configs',
          builder: (context, state) => const PerfilPaiConfigsScreen(),
        ),
        GoRoute(
          path: '/mudar-avatar',
          builder: (context, state) => const MudarAvatarScreen(),
        ),
        GoRoute(
          path: '/seguranca-config',
          builder: (context, state) => const SegurancaConfigScreen(),
        ),
        // Lista de vídeos por gênero (versão YouTube)
        GoRoute(
          path: '/videos/:genero',
          builder: (context, state) {
            final genero = state.pathParameters['genero']!;
            return ListaVideosYoutubeScreen(genero: genero); // ✅ Nova versão
          },
        ),
        // Editar perfil filho
        GoRoute(
          path: '/editar-perfil-filho',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return EditarPerfilFilhoScreen(
              perfilIndex: extra['perfilIndex'] as int,
              perfilAtual: extra['perfilAtual'] as Map<String, dynamic>,
            );
          },
        ),

        // Player do YouTube
        GoRoute(
          path: '/player',
          builder: (context, state) {
            final video = state.extra as VideoModelYoutube; // ✅ Modelo YouTube
            return VideoPlayerYoutubeScreen(video: video); // ✅ Player YouTube
          },
        ),
        // 🎬 ROTAS ADMIN - Gerenciamento de Vídeos
        GoRoute(
          path: '/admin/gerenciar-videos',
          name: 'admin-gerenciar-videos',
          builder: (context, state) => const AdminGerenciarVideosScreen(),
        ),

        GoRoute(
          path: '/admin/adicionar-video',
          name: 'admin-adicionar-video',
          builder: (context, state) => const AdminAddVideoScreen(),
        ),

        // Adicionar vídeo (admin) - apenas cola o link
        GoRoute(
          path: '/admin-add-video',
          builder: (context, state) => const AdminAddVideoScreen(),
        ),
        // Gerenciar vídeos (admin) - listar e gerenciar
        GoRoute(
          path: '/admin-videos',
          builder: (context, state) => const AdminListarVideosScreen(),
        ),
        GoRoute(
          path: '/tema-config',
          builder: (context, state) => const TemaConfigScreen(),
        ),
      ],
    );

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
            routerConfig: router,
          );
        },
      ),
    );
  }
}
