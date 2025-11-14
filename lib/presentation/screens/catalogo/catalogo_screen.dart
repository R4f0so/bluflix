import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  bool _isLoading = true;
  List<String> _generosVisiveis = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );
      final appTema = Provider.of<AppTema>(context, listen: false);

      print("🔵 Carregando dados do usuário...");
      print("   perfilAtivoApelido: ${perfilProvider.perfilAtivoApelido}");

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();

          // ✅ Verificar se o usuário é admin
          final tipoUsuario = data?['tipoUsuario'] ?? '';
          _isAdmin = tipoUsuario == 'admin';
          print("🎬 Usuário é admin? $_isAdmin");

          await appTema.loadThemeFromFirestore();

          if (perfilProvider.perfilAtivoApelido != null) {
            print(
              "✅ Usando perfil ativo: ${perfilProvider.perfilAtivoApelido}",
            );

            // Carregar preferências baseado no tipo de perfil
            if (perfilProvider.isPerfilPai) {
              // ✅ ATUALIZADO: Gêneros educacionais para o BluFlix
              _generosVisiveis = [
                'Educação',
                'Animação',
                'Música',
                'Natureza',
                'Ciências',
                'Arte',
                'Histórias',
                'Jogos',
              ];
            } else {
              // Perfil filho vê apenas os gêneros das preferências
              final perfisFilhos =
                  data?['perfisFilhos'] as List<dynamic>? ?? [];

              final perfilFilhoAtual = perfisFilhos.firstWhere(
                (perfil) =>
                    perfil['apelido'] == perfilProvider.perfilAtivoApelido,
                orElse: () => null,
              );

              if (perfilFilhoAtual != null) {
                final interesses =
                    perfilFilhoAtual['interesses'] as List<dynamic>? ?? [];
                _generosVisiveis = List<String>.from(interesses);
              }
            }
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("❌ Erro ao carregar dados: $e");
      setState(() => _isLoading = false);
    }
  }

  void _mostrarMenuPerfil(bool mostrarOpcoesAdmin) {
    final appTema = Provider.of<AppTema>(context, listen: false);
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    final userName = perfilProvider.perfilAtivoApelido ?? 'Usuário';
    final userAvatar = perfilProvider.perfilAtivoAvatar ?? 'assets/avatar1.png';

    // 🔍 DEBUG
    print('🔍 DEBUG _mostrarMenuPerfil (catalogo):');
    print('   _isAdmin: $_isAdmin');
    print('   perfilProvider.isPerfilPai: ${perfilProvider.isPerfilPai}');
    print('   mostrarOpcoesAdmin (parâmetro): $mostrarOpcoesAdmin');

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.topRight,
          insetPadding: const EdgeInsets.only(top: 70, right: 20),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appTema.isDarkMode
                        ? Colors.grey[850]
                        : Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: AssetImage(userAvatar),
                          ),
                          if (mostrarOpcoesAdmin)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: appTema.isDarkMode
                                        ? Colors.grey[900]!
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                color: appTema.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: mostrarOpcoesAdmin
                                    ? Colors.orange.withValues(alpha: 0.2)
                                    : Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: mostrarOpcoesAdmin
                                      ? Colors.orange
                                      : Colors.blue,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                mostrarOpcoesAdmin
                                    ? 'ADMINISTRADOR'
                                    : 'PERFIL PRINCIPAL',
                                style: TextStyle(
                                  color: mostrarOpcoesAdmin
                                      ? Colors.orange
                                      : Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _buildMenuItem(
                  icon: Icons.account_circle_outlined,
                  label: 'Mudar Avatar',
                  isDarkMode: appTema.isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/mudar-avatar');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.people_outline,
                  label: 'Mudar Perfil',
                  isDarkMode: appTema.isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/mudar-perfil');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  label: 'Adicionar Familiar',
                  isDarkMode: appTema.isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/adicionar-perfis');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Configurações',
                  isDarkMode: appTema.isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/perfil-configs');
                  },
                ),

                // ✅ Opções de Admin (apenas se for admin E perfil pai ativo)
                if (mostrarOpcoesAdmin) ...[
                  const Divider(height: 1),

                  _buildMenuItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Painel Administrador',
                    isDarkMode: appTema.isDarkMode,
                    iconColor: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/gerenciamento-admin');
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.video_library,
                    label: 'Gerenciar Vídeos',
                    isDarkMode: appTema.isDarkMode,
                    iconColor: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/gerenciar-videos');
                    },
                  ),
                ],

                const Divider(height: 1),

                _buildMenuItem(
                  icon: Icons.logout,
                  label: 'Sair',
                  isDestructive: true,
                  isDarkMode: appTema.isDarkMode,
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    if (mounted) context.go('/options');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool isDestructive = false,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive
                  ? Colors.red
                  : (iconColor ??
                        (isDarkMode ? Colors.white70 : Colors.black87)),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isDestructive
                    ? Colors.red
                    : (isDarkMode ? Colors.white : Colors.black87),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);
    // ✅ listen: true para rebuild quando perfil mudar
    final perfilProvider = Provider.of<PerfilProvider>(context);
    final userName = perfilProvider.perfilAtivoApelido ?? 'Usuário';
    final userAvatar = perfilProvider.perfilAtivoAvatar ?? 'assets/avatar1.png';

    // ✅ Calcula se deve mostrar opções de admin
    final bool mostrarOpcoesAdmin = _isAdmin && perfilProvider.isPerfilPai;

    // 🔍 DEBUG
    print('🔍 DEBUG catalogo_screen BUILD:');
    print('   _isAdmin: $_isAdmin');
    print('   perfilProvider.isPerfilPai: ${perfilProvider.isPerfilPai}');
    print('   userName: $userName');
    print('   mostrarOpcoesAdmin: $mostrarOpcoesAdmin');

    if (_isLoading) {
      return Scaffold(
        backgroundColor: appTema.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFA9DBF4)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(appTema.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Seta de voltar (APENAS para perfil pai)
                    if (perfilProvider.isPerfilPai)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        color: appTema.textColor,
                        onPressed: () => context.go('/gerenciamento-pais'),
                      ),
                    const Spacer(),

                    // ✅ Badge de Admin (apenas se for admin E perfil pai)
                    if (mostrarOpcoesAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange, width: 1.5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              color: Colors.orange,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(width: 8),
                    const ThemeToggleButton(),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _mostrarMenuPerfil(mostrarOpcoesAdmin),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(userAvatar),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Olá, $userName!',
                    style: TextStyle(
                      color: appTema.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      if (_generosVisiveis.contains('Relaxamento'))
                        _buildGeneroCard(
                          emoji: '😴',
                          genero: 'Relaxamento',
                          cor: Colors.blue,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Animação'))
                        _buildGeneroCard(
                          emoji: '🎨',
                          genero: 'Animação',
                          cor: Colors.purple,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Música'))
                        _buildGeneroCard(
                          emoji: '🎵',
                          genero: 'Música',
                          cor: Colors.pink,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Natureza'))
                        _buildGeneroCard(
                          emoji: '🌿',
                          genero: 'Natureza',
                          cor: Colors.green,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Ciências'))
                        _buildGeneroCard(
                          emoji: '🔬',
                          genero: 'Ciências',
                          cor: Colors.cyan,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Arte'))
                        _buildGeneroCard(
                          emoji: '🖌️',
                          genero: 'Arte',
                          cor: Colors.orange,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Histórias'))
                        _buildGeneroCard(
                          emoji: '📖',
                          genero: 'Histórias',
                          cor: Colors.brown,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Jogos'))
                        _buildGeneroCard(
                          emoji: '🎮',
                          genero: 'Jogos',
                          cor: Colors.red,
                          appTema: appTema,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneroCard({
    required String emoji,
    required String genero,
    required Color cor,
    required AppTema appTema,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/videos/$genero');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: appTema.isDarkMode
                ? [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.12),
                  ]
                : [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.08),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: appTema.isDarkMode
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            Text(
              genero,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTema.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
