import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  bool _isLoading = true;
  List<String> _generosVisiveis = [];

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

          await appTema.loadThemeFromFirestore();

          if (perfilProvider.perfilAtivoApelido != null) {
            print(
              "✅ Usando perfil ativo: ${perfilProvider.perfilAtivoApelido}",
            );

            // Carregar preferências baseado no tipo de perfil
            if (perfilProvider.isPerfilPai) {
              // Perfil pai vê todos os gêneros
              _generosVisiveis = [
                'Ação',
                'Comédia',
                'Drama',
                'Terror',
                'Ficção Científica',
                'Romance',
                'Animação',
                'Documentário',
              ];
            } else {
              // Perfil filho vê apenas os gêneros das preferências
              final perfisFilhos =
                  data?['perfis_filhos'] as List<dynamic>? ?? [];

              final perfilFilhoAtual = perfisFilhos.firstWhere(
                (perfil) =>
                    perfil['apelido'] == perfilProvider.perfilAtivoApelido,
                orElse: () => null,
              );

              if (perfilFilhoAtual != null) {
                final generosFavoritos =
                    perfilFilhoAtual['generosFavoritos'] as List<dynamic>? ??
                    [];
                _generosVisiveis = List<String>.from(generosFavoritos);
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

  void _mostrarMenuPerfil() {
    final appTema = Provider.of<AppTema>(context, listen: false);
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    final userName = perfilProvider.perfilAtivoApelido ?? 'Usuário';
    final userAvatar = perfilProvider.perfilAtivoAvatar ?? 'assets/avatar1.png';

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
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage(userAvatar),
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
                            Text(
                              perfilProvider.isPerfilPai
                                  ? 'Perfil Principal'
                                  : 'Perfil Filho',
                              style: TextStyle(
                                color: appTema.textSecondaryColor,
                                fontSize: 12,
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

                const Divider(height: 1),

                _buildMenuItem(
                  icon: Icons.logout,
                  label: 'Sair',
                  isDestructive: true,
                  isDarkMode: appTema.isDarkMode,
                  onTap: () async {
                    Navigator.pop(context);
                    _fazerLogout();
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
  }) {
    final color = isDestructive
        ? Colors.red
        : (isDarkMode ? Colors.white : Colors.black);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fazerLogout() async {
    final appTema = Provider.of<AppTema>(context, listen: false);
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text('Sair', style: TextStyle(color: appTema.textColor)),
        content: Text(
          'Deseja realmente sair da sua conta?',
          style: TextStyle(color: appTema.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: appTema.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      print("════════════════════════════════");
      print("🚪 FAZENDO LOGOUT");
      print("   Tema atual: ${appTema.isDarkMode ? 'Escuro' : 'Claro'}");

      await FirebaseAuth.instance.signOut();
      await perfilProvider.clearPerfilAtivo();

      print("   Tema após logout: ${appTema.isDarkMode ? 'Escuro' : 'Claro'}");
      print("   (Tema NÃO deve mudar no logout)");
      print("════════════════════════════════");

      if (mounted) context.go('/options');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);
    final perfilProvider = Provider.of<PerfilProvider>(context);
    final userName = perfilProvider.perfilAtivoApelido ?? 'Usuário';
    final userAvatar = perfilProvider.perfilAtivoAvatar ?? 'assets/avatar1.png';

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
              // ═══════════════════════════════════════════════════════
              // APPBAR - SETA VOLTAR (SÓ PARA PAI), TEMA E AVATAR
              // ═══════════════════════════════════════════════════════
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
                    const ThemeToggleButton(),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _mostrarMenuPerfil,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(userAvatar),
                      ),
                    ),
                  ],
                ),
              ),

              // ═══════════════════════════════════════════════════════
              // SAUDAÇÃO
              // ═══════════════════════════════════════════════════════
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

              // ═══════════════════════════════════════════════════════
              // GRADE DE GÊNEROS
              // ═══════════════════════════════════════════════════════
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      if (_generosVisiveis.contains('Ação'))
                        _buildGeneroCard(
                          emoji: '💥',
                          genero: 'Ação',
                          cor: Colors.red,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Comédia'))
                        _buildGeneroCard(
                          emoji: '😂',
                          genero: 'Comédia',
                          cor: Colors.yellow,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Drama'))
                        _buildGeneroCard(
                          emoji: '🎭',
                          genero: 'Drama',
                          cor: Colors.purple,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Terror'))
                        _buildGeneroCard(
                          emoji: '👻',
                          genero: 'Terror',
                          cor: Colors.black,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Ficção Científica'))
                        _buildGeneroCard(
                          emoji: '🚀',
                          genero: 'Ficção Científica',
                          cor: Colors.blue,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Romance'))
                        _buildGeneroCard(
                          emoji: '💕',
                          genero: 'Romance',
                          cor: Colors.pink,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Animação'))
                        _buildGeneroCard(
                          emoji: '🎨',
                          genero: 'Animação',
                          cor: Colors.green,
                          appTema: appTema,
                        ),
                      if (_generosVisiveis.contains('Documentário'))
                        _buildGeneroCard(
                          emoji: '📚',
                          genero: 'Documentário',
                          cor: Colors.brown,
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

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: CARD DE GÊNERO
  // ═══════════════════════════════════════════════════════════════
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
