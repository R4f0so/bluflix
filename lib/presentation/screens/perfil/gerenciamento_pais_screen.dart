import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'package:bluflix/utils/dialogs/pin_verification_dialog.dart';

class GerenciamentoPaisScreen extends StatefulWidget {
  const GerenciamentoPaisScreen({super.key});

  @override
  State<GerenciamentoPaisScreen> createState() =>
      _GerenciamentoPaisScreenState();
}

class _GerenciamentoPaisScreenState extends State<GerenciamentoPaisScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _perfisFilhos = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfisFilhos();
  }

  Future<void> _carregarPerfisFilhos() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        setState(() => _isLoading = false);
        return;
      }

      print('🔍 Buscando perfis filhos para userId: ${user.uid}');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        print('❌ Documento do usuário não encontrado');
        setState(() => _isLoading = false);
        return;
      }

      final data = userDoc.data();

      final tipoUsuario = data?['tipoUsuario'] ?? '';
      _isAdmin = tipoUsuario == 'admin';
      final perfisFilhos = data?['perfisFilhos'] as List<dynamic>? ?? [];

      print('📊 Total de perfis filhos encontrados: ${perfisFilhos.length}');

      setState(() {
        // ✅ CORREÇÃO: Garante que interesses seja uma nova lista independente
        _perfisFilhos = perfisFilhos.map((p) {
          final perfil = Map<String, dynamic>.from(p);
          if (perfil.containsKey('interesses')) {
            perfil['interesses'] = List<String>.from(perfil['interesses'] ?? []);
          }
          return perfil;
        }).toList();
        _isLoading = false;
      });

      print('✅ Perfis filhos carregados: ${_perfisFilhos.length}');
    } catch (e) {
      print('❌ Erro ao carregar perfis filhos: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);
    // ✅ IMPORTANTE: listen: true para rebuild quando perfil mudar
    final perfilProvider = Provider.of<PerfilProvider>(context);
    final userName = perfilProvider.perfilAtivoApelido ?? 'Usuário';
    final userAvatar = perfilProvider.perfilAtivoAvatar ?? 'assets/avatar1.png';

    // ✅ Calcula diretamente aqui, usando o provider que está sendo observado
    final bool mostrarOpcoesAdmin = _isAdmin && perfilProvider.isPerfilPai;

    // 🔍 DEBUG: Verificar valores
    print('🔍 DEBUG gerenciamento_pais_screen BUILD:');
    print('   _isAdmin: $_isAdmin');
    print('   perfilProvider.isPerfilPai: ${perfilProvider.isPerfilPai}');
    print('   userName: $userName');
    print('   mostrarOpcoesAdmin: $mostrarOpcoesAdmin');

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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFA9DBF4)),
                )
              : Column(
                  children: [
                    // AppBar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Spacer(),
                          const ThemeToggleButton(),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _mostrarMenuPerfil(mostrarOpcoesAdmin),
                            child: mostrarOpcoesAdmin
                                ? Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: AssetImage(userAvatar),
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
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage(userAvatar),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar e Saudação
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(userAvatar),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Olá, $userName!',
                            style: TextStyle(
                              color: appTema.textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Título
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Gerenciar Perfis Filhos',
                          style: TextStyle(
                            color: appTema.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Grade de perfis
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _perfisFilhos.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.family_restroom,
                                      size: 80,
                                      color: appTema.textSecondaryColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhum perfil filho criado',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: appTema.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Toque no botão abaixo para adicionar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: appTema.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.75,
                                    ),
                                itemCount: _perfisFilhos.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == _perfisFilhos.length) {
                                    return _buildCardAdicionarFamiliar(appTema);
                                  }

                                  final perfil = _perfisFilhos[index];
                                  return _buildCardPerfilFilho(
                                    perfil,
                                    appTema,
                                    index,
                                  );
                                },
                              ),
                      ),
                    ),

                    // Botão Adicionar Familiar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await context.push('/adicionar-perfis');
                            if (!mounted) return;
                            _carregarPerfisFilhos();
                          },
                          icon: const Icon(Icons.person_add, size: 24),
                          label: const Text(
                            'Adicionar Familiar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botão Ver Catálogo
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/catalogo'),
                          icon: const Icon(Icons.video_library, size: 24),
                          label: const Text(
                            'Ver Catálogo Completo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA9DBF4),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCardAdicionarFamiliar(AppTema appTema) {
    return GestureDetector(
      onTap: () async {
        await context.push('/adicionar-perfis');
        if (!mounted) return;
        _carregarPerfisFilhos();
      },
      child: Container(
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: appTema.isDarkMode
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.15),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 60, color: appTema.textColor),
            const SizedBox(height: 12),
            Text(
              'Adicionar\nFamiliar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTema.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPerfilFilho(
    Map<String, dynamic> perfil,
    AppTema appTema,
    int index,
  ) {
    final apelido = perfil['apelido'] ?? 'Perfil';
    final avatar = perfil['avatar'] ?? 'assets/avatar1.png';

    return GestureDetector(
      onTap: () => _selecionarPerfilFilho(perfil),
      child: Container(
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: appTema.isDarkMode
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 35, backgroundImage: AssetImage(avatar)),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  apelido,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: appTema.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _mostrarOpcoesEdicao(perfil, index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA9DBF4),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/analytics/$apelido');
                  },
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text(
                    'Analytics',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  void _mostrarMenuPerfil(bool mostrarOpcoesAdmin) {
    final appTema = Provider.of<AppTema>(context, listen: false);
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    final userName = perfilProvider.perfilAtivoApelido ?? 'Usuário';
    final userAvatar = perfilProvider.perfilAtivoAvatar ?? 'assets/avatar1.png';

    // 🔍 DEBUG
    print('🔍 DEBUG _mostrarMenuPerfil:');
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
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push('/adicionar-perfis');
                    if (!mounted) return;
                    _carregarPerfisFilhos();
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

                // Opções de Admin (apenas se for admin E perfil pai ativo)
                if (mostrarOpcoesAdmin) ...[
                  const Divider(height: 1),

                  _buildMenuItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Painel Administrador',
                    isDarkMode: appTema.isDarkMode,
                    iconColor: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/gerenciamento-admin');
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
                    _realizarLogout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarOpcoesEdicao(Map<String, dynamic> perfil, int index) {
    final appTema = Provider.of<AppTema>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              icon: Icons.edit,
              label: 'Editar Perfil',
              isDarkMode: appTema.isDarkMode,
              onTap: () async {
                final navigator = Navigator.of(modalContext);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final router = GoRouter.of(context);

                navigator.pop();

                await _carregarPerfisFilhos();

                if (!mounted) return;

                if (index >= _perfisFilhos.length) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Perfil não encontrado. A lista foi atualizada.',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (!mounted) return;
                final pinVerificado = await VerificarPinDialog.verificar(
                  context,
                );
                if (!pinVerificado || !mounted) return;

                final resultado = await router.push(
                  '/editar-perfil-filho',
                  extra: {
                    'perfilIndex': index,
                    'perfilAtual': _perfisFilhos[index],
                  },
                );

                if (resultado == true && mounted) {
                  await _carregarPerfisFilhos();

                  if (!mounted) return;

                  final perfilProvider = Provider.of<PerfilProvider>(
                    context,
                    listen: false,
                  );

                  if (!perfilProvider.isPerfilPai &&
                      index < _perfisFilhos.length) {
                    final perfilEditado = _perfisFilhos[index];

                    if (perfilProvider.perfilAtivoApelido ==
                        perfil['apelido']) {
                      await perfilProvider.setPerfilAtivo(
                        apelido: perfilEditado['apelido'],
                        avatar: perfilEditado['avatar'],
                        isPai: false,
                      );

                      if (!mounted) return;

                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Perfil atualizado! As alterações já estão ativas.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }
              },
            ),
            _buildMenuItem(
              icon: Icons.delete,
              label: 'Excluir Perfil',
              isDarkMode: appTema.isDarkMode,
              onTap: () {
                Navigator.of(modalContext).pop();
                _confirmarExclusao(index);
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarPerfilFilho(Map<String, dynamic> perfil) async {
    print("🔵 _selecionarPerfilFilho chamado");
    print("   Perfil selecionado: ${perfil['apelido']}");

    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    final apelido = perfil['apelido'] ?? 'Usuário';
    final avatar = perfil['avatar'] ?? 'assets/avatar1.png';

    print("   Apelido: $apelido");
    print("   Avatar: $avatar");

    if (!mounted) return;

    final pinVerificado = await VerificarPinDialog.verificar(context);

    if (!mounted) return;

    if (!pinVerificado) {
      print("❌ PIN não verificado - cancelando troca de perfil");
      return;
    }

    print("✅ PIN verificado - permitindo troca para perfil filho");

    await perfilProvider.setPerfilAtivo(
      apelido: apelido,
      avatar: avatar,
      isPai: false,
    );

    print("✅ Perfil salvo");

    if (!mounted) return;

    context.go('/catalogo');
  }

  Future<void> _confirmarExclusao(int index) async {
    final appTema = Provider.of<AppTema>(context, listen: false);
    final perfil = _perfisFilhos[index];
    final apelido = perfil['apelido'] ?? 'este perfil';

    if (!mounted) return;
    final pinVerificado = await VerificarPinDialog.verificar(context);
    if (!pinVerificado) return;

    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Excluir Perfil',
                style: TextStyle(color: appTema.textColor),
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja realmente excluir o perfil "$apelido"?\n\nEsta ação não pode ser desfeita.',
          style: TextStyle(color: appTema.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: appTema.textSecondaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _excluirPerfilFilho(index);
    }
  }

  Future<void> _excluirPerfilFilho(int index) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _mostrarMensagem('Usuário não autenticado');
        return;
      }

      final perfilExcluido = _perfisFilhos[index];
      final apelidoExcluido = perfilExcluido['apelido'];

      _perfisFilhos.removeAt(index);

      await _firestore.collection('users').doc(user.uid).update({
        'perfisFilhos': _perfisFilhos,
      });

      print("✅ Perfil excluído com sucesso!");

      if (!mounted) return;

      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );

      if (perfilProvider.perfilAtivoApelido == apelidoExcluido) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          await perfilProvider.setPerfilAtivo(
            apelido: data?['apelido'] ?? 'Usuário',
            avatar: data?['avatar'] ?? 'assets/avatar1.png',
            isPai: true,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Perfil excluído! Voltando para o perfil principal.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil "$apelidoExcluido" excluído com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("❌ Erro ao excluir perfil: $e");
      if (!mounted) return;

      _mostrarMensagem('Erro ao excluir: ${e.toString()}');
    }
  }

  Future<void> _realizarLogout() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      _mostrarMensagem('Erro ao sair: $e');
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), duration: const Duration(seconds: 3)),
    );
  }
}