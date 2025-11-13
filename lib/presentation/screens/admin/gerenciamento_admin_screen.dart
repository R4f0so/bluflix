import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'package:bluflix/utils/guards/admin_guard.dart';

class GerenciamentoAdminScreen extends StatefulWidget {
  const GerenciamentoAdminScreen({super.key});

  @override
  State<GerenciamentoAdminScreen> createState() =>
      _GerenciamentoAdminScreenState();
}

class _GerenciamentoAdminScreenState extends State<GerenciamentoAdminScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  String _adminNome = 'Admin';
  String _adminAvatar = 'assets/avatar1.png';
  int _totalVideos = 0;
  int _totalUsuarios = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdminGuard.checkAdminAccess(context);
    _carregarDadosAdmin();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ NOVO: Detecta quando o app volta ao primeiro plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 App voltou ao primeiro plano - recarregando dados admin');
      _carregarDadosAdmin();
    }
  }

  Future<void> _carregarDadosAdmin() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          _adminNome = data?['apelido'] ?? 'Admin';
          _adminAvatar = data?['avatar'] ?? 'assets/avatar1.png';

          if (mounted) {
            final perfilProvider = Provider.of<PerfilProvider>(
              context,
              listen: false,
            );
            await perfilProvider.setPerfilAtivo(
              apelido: _adminNome,
              avatar: _adminAvatar,
              isPai: true,
            );
          }
        }

        final videosSnapshot = await FirebaseFirestore.instance
            .collection('videos_youtube')
            .where('ativo', isEqualTo: true)
            .get();
        _totalVideos = videosSnapshot.docs.length;

        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .get();
        _totalUsuarios = usersSnapshot.docs.length;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Erro ao carregar dados do admin: $e');
      setState(() => _isLoading = false);
    }
  }

  void _mostrarMenuAdmin() {
    final appTema = Provider.of<AppTema>(context, listen: false);

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
                            backgroundImage: AssetImage(_adminAvatar),
                          ),
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
                              _adminNome,
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
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'ADMINISTRADOR',
                                style: TextStyle(
                                  color: Colors.orange,
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

                // Mudar Avatar
                _buildMenuItem(
                  icon: Icons.account_circle_outlined,
                  label: 'Mudar Avatar',
                  isDarkMode: appTema.isDarkMode,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/mudar-avatar');
                    // ✅ Recarregar dados ao retornar
                    if (mounted) _carregarDadosAdmin();
                  },
                ),

                // Mudar Perfil
                _buildMenuItem(
                  icon: Icons.people_outline,
                  label: 'Mudar Perfil',
                  isDarkMode: appTema.isDarkMode,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/mudar-perfil');
                    // ✅ Recarregar dados ao retornar
                    if (mounted) _carregarDadosAdmin();
                  },
                ),

                // Adicionar Familiar
                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  label: 'Adicionar Familiar',
                  isDarkMode: appTema.isDarkMode,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/adicionar-perfis');
                    // ✅ Recarregar dados ao retornar
                    if (mounted) _carregarDadosAdmin();
                  },
                ),

                // Configurações
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Configurações',
                  isDarkMode: appTema.isDarkMode,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/perfil-configs');
                    // ✅ Recarregar dados ao retornar
                    if (mounted) _carregarDadosAdmin();
                  },
                ),

                const Divider(height: 1),

                // Painel Administrador
                _buildMenuItem(
                  icon: Icons.admin_panel_settings,
                  label: 'Painel Administrador',
                  isDarkMode: appTema.isDarkMode,
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // Já está na tela, apenas fecha o menu
                  },
                ),

                // Gerenciar Vídeos
                _buildMenuItem(
                  icon: Icons.video_library,
                  label: 'Gerenciar Vídeos',
                  isDarkMode: appTema.isDarkMode,
                  iconColor: Colors.orange,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/admin/gerenciar-videos');
                    // ✅ Recarregar dados ao retornar
                    if (mounted) _carregarDadosAdmin();
                  },
                ),

                const Divider(height: 1),

                // Sair
                _buildMenuItem(
                  icon: Icons.logout,
                  label: 'Sair',
                  isDestructive: true,
                  isDarkMode: appTema.isDarkMode,
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.go('/options');
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
                    const Spacer(),
                    // ✅ NOVO: Botão de atualizar manualmente
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: appTema.textColor,
                        size: 24,
                      ),
                      onPressed: () {
                        print('🔄 Atualizando dados manualmente');
                        _carregarDadosAdmin();
                      },
                      tooltip: 'Atualizar dados',
                    ),
                    const SizedBox(width: 8),
                    const ThemeToggleButton(),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _mostrarMenuAdmin,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(_adminAvatar),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: appTema.backgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Olá, $_adminNome!',
                          style: TextStyle(
                            color: appTema.textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange,
                              width: 1.5,
                            ),
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Painel de Controle',
                      style: TextStyle(
                        color: appTema.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.video_library,
                        label: 'Vídeos',
                        value: '$_totalVideos',
                        color: Colors.blue,
                        appTema: appTema,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people,
                        label: 'Usuários Cadastrados',
                        value: '$_totalUsuarios',
                        color: Colors.green,
                        appTema: appTema,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        icon: Icons.video_library,
                        label: 'Gerenciar\nVídeos',
                        color: Colors.orange,
                        appTema: appTema,
                        onTap: () async {
                          await context.push('/admin/gerenciar-videos');
                          if (mounted) _carregarDadosAdmin();
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.add_circle_outline,
                        label: 'Adicionar\nVídeo',
                        color: Colors.purple,
                        appTema: appTema,
                        onTap: () async {
                          await context.push('/admin/adicionar-video');
                          if (mounted) _carregarDadosAdmin();
                        },
                      ),
                      // ✅ NOVO: Botão Gerenciar Perfis Filhos
                      _buildActionCard(
                        icon: Icons.family_restroom,
                        label: 'Gerenciar\nPerfis Filhos',
                        color: Colors.green,
                        appTema: appTema,
                        onTap: () async {
                          await context.push('/gerenciamento-pais');
                          if (mounted) _carregarDadosAdmin();
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.play_circle_outline,
                        label: 'Ver Catálogo\n(como usuário)',
                        color: Colors.blue,
                        appTema: appTema,
                        onTap: () async {
                          await context.push('/catalogo');
                          if (mounted) _carregarDadosAdmin();
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.settings,
                        label: 'Configurações\ndo Sistema',
                        color: Colors.grey,
                        appTema: appTema,
                        onTap: () async {
                          await context.push('/perfil-configs');
                          if (mounted) _carregarDadosAdmin();
                        },
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required AppTema appTema,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appTema.isDarkMode
              ? [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ]
              : [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: appTema.textSecondaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required AppTema appTema,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appTema.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}