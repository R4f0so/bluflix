import 'package:bluflix/admin_gerenciar_videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'mudar_avatar.dart';
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
import 'gerenciamento_pais.dart';
import 'perfil_configs.dart';
import 'perfilpai_configs.dart';
import 'seguranca_config.dart';
import 'tema_config.dart';
import 'criapin.dart';
import 'preferencias_filho.dart';
import 'video_model_youtube.dart';
import 'lista_videos_screen_youtube.dart';
import 'video_player_youtube_screen.dart';
import 'admin_add_video_screen.dart';
import 'admin_listar_videos_screen.dart';
import 'editar_perfil_filho.dart';

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
