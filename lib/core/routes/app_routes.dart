import 'package:go_router/go_router.dart';
import 'package:bluflix/presentation/screens/auth/splash_screen.dart';
import 'package:bluflix/presentation/screens/auth/options_screen.dart';
import 'package:bluflix/presentation/screens/auth/login_screen.dart';
import 'package:bluflix/presentation/screens/auth/cadastro_screen.dart';
import 'package:bluflix/presentation/screens/auth/esqueci_senha_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/avatar_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/apelido_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/criapin_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/avatar_filho_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/apelido_filho_screen.dart';
import 'package:bluflix/presentation/screens/onboarding/preferencias_filho_screen.dart';
import 'package:bluflix/presentation/screens/catalogo/catalogo_screen.dart';
import 'package:bluflix/presentation/screens/catalogo/lista_videos_screen_youtube.dart';
import 'package:bluflix/presentation/screens/catalogo/video_player_youtube_screen.dart';
import 'package:bluflix/presentation/screens/perfil/adicionar_perfis_screen.dart';
import 'package:bluflix/presentation/screens/perfil/mudar_perfil_screen.dart';
import 'package:bluflix/presentation/screens/perfil/gerenciamento_pais_screen.dart';
import 'package:bluflix/presentation/screens/perfil/mudar_avatar_screen.dart';
import 'package:bluflix/presentation/screens/perfil/editar_perfil_filho_screen.dart';
import 'package:bluflix/presentation/screens/configuracoes/perfil_configs_screen.dart';
import 'package:bluflix/presentation/screens/configuracoes/perfilpai_configs_screen.dart';
import 'package:bluflix/presentation/screens/configuracoes/seguranca_config_screen.dart';
import 'package:bluflix/presentation/screens/configuracoes/tema_config_screen.dart';
import 'package:bluflix/presentation/screens/admin/gerenciamento_admin_screen.dart';
import 'package:bluflix/presentation/screens/admin/admin_gerenciar_videos_screen.dart';
import 'package:bluflix/presentation/screens/admin/admin_add_video_screen.dart';
import 'package:bluflix/presentation/screens/admin/admin_listar_videos_screen.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';
import 'package:bluflix/presentation/screens/analytics/perfil_filho_analytics_screen.dart';

/// Configuração de rotas do app
class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ═══════════════════════════════════════════════════════════════
      // AUTENTICAÇÃO
      // ═══════════════════════════════════════════════════════════════
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/options',
        name: 'options',
        builder: (context, state) => const OptionsScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/cadastro',
        name: 'cadastro',
        builder: (context, state) => const CadastroScreen(),
      ),
      GoRoute(
        path: '/esqueci-senha',
        name: 'esqueci-senha',
        builder: (context, state) => const EsqueciSenhaScreen(),
      ),

      // ═══════════════════════════════════════════════════════════════
      // ONBOARDING - PERFIL PAI
      // ═══════════════════════════════════════════════════════════════
      GoRoute(
        path: '/avatar',
        name: 'avatar',
        builder: (context, state) => const AvatarScreen(),
      ),
      GoRoute(
        path: '/apelido',
        name: 'apelido',
        builder: (context, state) {
          final avatar = state.extra as String?;
          return ApelidoScreen(selectedAvatar: avatar ?? 'assets/avatar1.png');
        },
      ),
      GoRoute(
        path: '/criapin',
        name: 'criapin',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return CriaPinScreen(
            apelido: extra['apelido']!,
            avatar: extra['avatar']!,
          );
        },
      ),

      // ═══════════════════════════════════════════════════════════════
      // ONBOARDING - PERFIL FILHO
      // ═══════════════════════════════════════════════════════════════
      GoRoute(
        path: '/avatar-filho',
        name: 'avatar-filho',
        builder: (context, state) => const AvatarFilhoScreen(),
      ),
      GoRoute(
        path: '/apelido-filho',
        name: 'apelido-filho',
        builder: (context, state) {
          final avatar = state.extra as String?;
          return ApelidoFilhoScreen(
            selectedAvatar: avatar ?? 'assets/avatar_crianca1.png',
          );
        },
      ),
      GoRoute(
        path: '/preferencias-filho',
        name: 'preferencias-filho',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return PreferenciasFilhoScreen(
            apelido: extra['apelido']!,
            avatar: extra['avatar']!,
          );
        },
      ),

      // ═══════════════════════════════════════════════════════════════
      // GERENCIAMENTO DE PERFIS
      // ═══════════════════════════════════════════════════════════════
      GoRoute(
        path: '/gerenciamento-pais',
        name: 'gerenciamento-pais',
        builder: (context, state) => const GerenciamentoPaisScreen(),
      ),
      GoRoute(
        path: '/adicionar-perfis',
        name: 'adicionar-perfis',
        builder: (context, state) => const AdicionarPerfisScreen(),
      ),
      GoRoute(
        path: '/mudar-perfil',
        name: 'mudar-perfil',
        builder: (context, state) => const MudarPerfilScreen(),
      ),
      GoRoute(
        path: '/mudar-avatar',
        name: 'mudar-avatar',
        builder: (context, state) => const MudarAvatarScreen(),
      ),
      GoRoute(
        path: '/editar-perfil-filho',
        name: 'editar-perfil-filho',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return EditarPerfilFilhoScreen(
            perfilIndex: extra['perfilIndex'] as int,
            perfilAtual: extra['perfilAtual'] as Map<String, dynamic>,
          );
        },
      ),

      // ═══════════════════════════════════════════════════════════════
      // CONFIGURAÇÕES
      // ═══════════════════════════════════════════════════════════════
      GoRoute(
        path: '/perfil-configs',
        name: 'perfil-configs',
        builder: (context, state) => const PerfilConfigsScreen(),
      ),
      GoRoute(
        path: '/perfilpai-configs',
        name: 'perfilpai-configs',
        builder: (context, state) => const PerfilPaiConfigsScreen(),
      ),
      GoRoute(
        path: '/seguranca-config',
        name: 'seguranca-config',
        builder: (context, state) => const SegurancaConfigScreen(),
      ),
      GoRoute(
        path: '/tema-config',
        name: 'tema-config',
        builder: (context, state) => const TemaConfigScreen(),
      ),

      // ═══════════════════════════════════════════════════════════════
      // CATÁLOGO E VÍDEOS
      // ═══════════════════════════════════════════════════════════════
      GoRoute(
        path: '/catalogo',
        name: 'catalogo',
        builder: (context, state) => const CatalogoScreen(),
      ),
      GoRoute(
        path: '/videos/:genero',
        name: 'videos-genero',
        builder: (context, state) {
          final genero = state.pathParameters['genero']!;
          return ListaVideosYoutubeScreen(genero: genero);
        },
      ),
      GoRoute(
        path: '/player',
        name: 'player',
        builder: (context, state) {
          final video = state.extra as VideoModelYoutube;
          return VideoPlayerYoutubeScreen(video: video);
        },
      ),

      // ═══════════════════════════════════════════════════════════════
      // ADMIN - PAINEL E GERENCIAMENTO
      // ═══════════════════════════════════════════════════════════════
      GoRoute(
        path: '/gerenciamento-admin',
        name: 'gerenciamento-admin',
        builder: (context, state) => const GerenciamentoAdminScreen(),
      ),
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
      GoRoute(
        path: '/admin-videos',
        name: 'admin-listar-videos',
        builder: (context, state) => const AdminListarVideosScreen(),
      ),

      // ═══════════════════════════════════════════════════════════════
      // ANALYTICS
      // ═══════════════════════════════════════════════════════════════
      GoRoute(
        path: '/analytics/:perfilFilhoApelido',
        name: 'perfil-filho-analytics',
        builder: (context, state) {
          final perfilFilhoApelido = state.pathParameters['perfilFilhoApelido']!;
          return PerfilFilhoAnalyticsScreen(perfilFilhoApelido: perfilFilhoApelido);
        },
      ),
    ],
  );
}