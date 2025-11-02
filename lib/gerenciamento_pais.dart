import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';

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

      final snapshot = await _firestore
          .collection('perfis_filhos')
          .where('userId', isEqualTo: user.uid)
          .get();

      print('📊 Total de perfis filhos encontrados: ${snapshot.docs.length}');

      setState(() {
        _perfisFilhos = snapshot.docs.map((doc) {
          final data = doc.data();
          print('✅ Perfil encontrado: ${data['apelido']} (ID: ${doc.id})');
          return {'id': doc.id, ...data};
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
    final perfilProvider = Provider.of<PerfilProvider>(context);
    final userName = perfilProvider.perfilAtivoApelido ?? 'Usuário';
    final userAvatar = perfilProvider.perfilAtivoAvatar ?? 'assets/avatar1.png';

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
                    // ═══════════════════════════════════════════════════
                    // APPBAR COM SETA VOLTAR, AVATAR E TOGGLE TEMA
                    // ═══════════════════════════════════════════════════
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Spacer(),
                          const ThemeToggleButton(),
                          const SizedBox(width: 8),
                          // Avatar clicável (menu)
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

                    // ═══════════════════════════════════════════════════
                    // AVATAR E SAUDAÇÃO DO PERFIL PAI
                    // ═══════════════════════════════════════════════════
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          // Avatar do perfil pai
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(userAvatar),
                          ),
                          const SizedBox(width: 16),
                          // Saudação
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

                    // ═══════════════════════════════════════════════════
                    // TÍTULO - GERENCIAR PERFIS
                    // ═══════════════════════════════════════════════════
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

                    // ═══════════════════════════════════════════════════
                    // GRADE DE PERFIS FILHOS
                    // ═══════════════════════════════════════════════════
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
                                      childAspectRatio: 0.85,
                                    ),
                                itemCount: _perfisFilhos.length + 1,
                                itemBuilder: (context, index) {
                                  // Card "Adicionar Familiar"
                                  if (index == _perfisFilhos.length) {
                                    return _buildCardAdicionarFamiliar(appTema);
                                  }

                                  // Card de perfil filho
                                  final perfil = _perfisFilhos[index];
                                  return _buildCardPerfilFilho(perfil, appTema);
                                },
                              ),
                      ),
                    ),

                    // ═══════════════════════════════════════════════════
                    // BOTÃO: VER CATÁLOGO COMPLETO
                    // ═══════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: CARD ADICIONAR FAMILIAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCardAdicionarFamiliar(AppTema appTema) {
    return GestureDetector(
      onTap: () async {
        await context.push('/adicionar-perfis'); // ✅ CORRIGIDO
        if (!mounted) return; // ✅ ADICIONADO
        _carregarPerfisFilhos(); // Recarrega após adicionar
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

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: CARD PERFIL FILHO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCardPerfilFilho(Map<String, dynamic> perfil, AppTema appTema) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(radius: 40, backgroundImage: AssetImage(avatar)),

            const SizedBox(height: 12),

            // Nome do perfil
            Text(
              apelido,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTema.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Botão Editar
            ElevatedButton(
              onPressed: () => _mostrarOpcoesEdicao(perfil),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA9DBF4),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Editar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // AÇÕES: MENU DE PERFIL (AVATAR) - IGUAL AO CATALOGO.DART
  // ═══════════════════════════════════════════════════════════════
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
                // Cabeçalho com avatar e nome
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

                // Itens do menu
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
                    if (!mounted) return; // ✅ ADICIONADO
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

  // ═══════════════════════════════════════════════════════════════
  // AÇÕES: OPÇÕES DE EDIÇÃO DO PERFIL FILHO
  // ═══════════════════════════════════════════════════════════════
  void _mostrarOpcoesEdicao(Map<String, dynamic> perfil) {
    final appTema = Provider.of<AppTema>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              icon: Icons.favorite,
              label: 'Editar Preferências',
              isDarkMode: appTema.isDarkMode,
              onTap: () async {
                Navigator.pop(context);
                await context.push('/definir-generos-favoritos');
                if (!mounted) return; // ✅ ADICIONADO
                _carregarPerfisFilhos();
              },
            ),
            _buildMenuItem(
              icon: Icons.delete,
              label: 'Excluir Perfil',
              isDarkMode: appTema.isDarkMode,
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoExcluirPerfilFilho(perfil['id']);
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: ITEM DO MENU
  // ═══════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════
  // AÇÕES: SELECIONAR PERFIL FILHO
  // ═══════════════════════════════════════════════════════════════
  Future<void> _selecionarPerfilFilho(Map<String, dynamic> perfil) async {
    // Obtém o provider ANTES de qualquer await
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    // Solicita PIN
    final pinCorreto = await _solicitarPIN(perfil['pin']);
    if (!pinCorreto) {
      if (!mounted) return;
      _mostrarMensagem('PIN incorreto!');
      return;
    }

    // Define o perfil ativo
    await perfilProvider.setPerfilAtivo(
      apelido: perfil['apelido'],
      avatar: perfil['avatar'],
      isPai: false,
    );

    if (!mounted) return;
    context.go('/catalogo');
  }

  // ═══════════════════════════════════════════════════════════════
  // DIÁLOGOS
  // ═══════════════════════════════════════════════════════════════
  Future<bool> _solicitarPIN(String pinCorreto) async {
    if (!mounted) return false; // ✅ VERIFICAÇÃO ANTES DE USAR CONTEXT

    final pinController = TextEditingController();
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Digite o PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: '****', counterText: ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final pinDigitado = pinController.text;
              Navigator.pop(context, pinDigitado == pinCorreto);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  void _mostrarDialogoExcluirPerfilFilho(String perfilId) async {
    // Solicita o PIN do perfil PAI (não do filho)
    final user = _auth.currentUser;
    if (user == null) return;

    // Buscar o PIN do perfil pai
    String? pinPai;
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      pinPai = userDoc.data()?['pin'];
    } catch (e) {
      _mostrarMensagem('Erro ao verificar PIN: $e');
      return;
    }

    if (pinPai == null) {
      _mostrarMensagem('PIN do perfil pai não encontrado');
      return;
    }

    // Solicita o PIN
    if (!mounted) return;
    final pinCorreto = await _solicitarPINExclusao(pinPai);
    if (!pinCorreto) {
      _mostrarMensagem('PIN incorreto!');
      return;
    }

    // Se o PIN estiver correto, mostra confirmação final
    if (!mounted) return; // ✅ VERIFICAÇÃO ANTES DE USAR CONTEXT
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Perfil Filho'),
        content: const Text(
          'Tem certeza que deseja excluir este perfil? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final sucesso = await _excluirPerfilFilho(perfilId);
              if (sucesso) {
                _carregarPerfisFilhos();
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<bool> _solicitarPINExclusao(String pinCorreto) async {
    if (!mounted) return false; // ✅ VERIFICAÇÃO ANTES DE USAR CONTEXT

    final pinController = TextEditingController();
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Digite seu PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o PIN do perfil pai para confirmar a exclusão'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '****',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final pinDigitado = pinController.text;
              Navigator.pop(context, pinDigitado == pinCorreto);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  // ═══════════════════════════════════════════════════════════════
  // AÇÕES PRINCIPAIS
  // ═══════════════════════════════════════════════════════════════
  Future<bool> _excluirPerfilFilho(String perfilId) async {
    try {
      await _firestore.collection('perfis_filhos').doc(perfilId).delete();
      _mostrarMensagem('Perfil filho excluído com sucesso!');
      return true;
    } catch (e) {
      _mostrarMensagem('Erro ao excluir perfil filho: $e');
      return false;
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
