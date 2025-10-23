import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';
import 'pin_verification.dart';

class AdicionarPerfisScreen extends StatefulWidget {
  const AdicionarPerfisScreen({super.key});

  @override
  State<AdicionarPerfisScreen> createState() => _AdicionarPerfisScreenState();
}

class _AdicionarPerfisScreenState extends State<AdicionarPerfisScreen> {
  List<Map<String, dynamic>> _perfisFilhos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfis();
  }

  void _mostrarOpcoesPerfi(
    int index,
    Map<String, dynamic> perfil,
    AppTema appTema,
  ) {
    final apelido = perfil['apelido'] ?? 'este perfil';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de arrastar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Cabeçalho
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                          perfil['avatar'] ?? 'assets/avatar1.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          apelido,
                          style: TextStyle(
                            color: appTema.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Opção Editar (desabilitada por enquanto)
                ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    color: appTema.textSecondaryColor,
                  ),
                  title: Text(
                    'Editar Perfil',
                    style: TextStyle(color: appTema.textSecondaryColor),
                  ),
                  subtitle: Text(
                    'Em desenvolvimento',
                    style: TextStyle(
                      color: appTema.textSecondaryColor.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Função em desenvolvimento...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                // Opção Excluir
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Excluir Perfil',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmarExclusao(index);
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _carregarPerfis() async {
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
          final perfis = data?['perfisFilhos'] as List<dynamic>? ?? [];

          setState(() {
            _perfisFilhos = perfis
                .map((p) => Map<String, dynamic>.from(p))
                .toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar perfis: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmarExclusao(int index) async {
    final perfil = _perfisFilhos[index];
    final apelido = perfil['apelido'] ?? 'este perfil';

    // ✅ Verifica se está montado antes de verificar PIN
    if (!mounted) return;

    // Primeiro verifica o PIN
    final pinVerificado = await VerificarPinDialog.verificar(context);
    if (!pinVerificado) {
      return; // Usuário cancelou ou PIN incorreto
    }

    // ✅ Verifica novamente após operação assíncrona
    if (!mounted) return;

    // Após verificar PIN, pede confirmação
    final appTema = Provider.of<AppTema>(context, listen: false);
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
      await _excluirPerfil(index);
    }
  }

  Future<void> _excluirPerfil(int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final perfilExcluido = _perfisFilhos[index];
      final apelidoExcluido = perfilExcluido['apelido'];

      // Remove da lista local
      _perfisFilhos.removeAt(index);

      // Atualiza no Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'perfisFilhos': _perfisFilhos},
      );

      print("✅ Perfil excluído com sucesso!");

      // ✅ Verifica se está montado antes de usar context
      if (!mounted) return;

      // Verifica se o perfil excluído era o ativo
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );

      if (perfilProvider.perfilAtivoApelido == apelidoExcluido) {
        // Se sim, volta para o perfil pai
        final userDoc = await FirebaseFirestore.instance
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

          // ✅ Verifica novamente após operação assíncrona
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
        // ✅ Verifica se está montado
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil "$apelidoExcluido" excluído com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Atualiza a tela
      setState(() {});
    } catch (e) {
      print("❌ Erro ao excluir perfil: $e");

      // ✅ Verifica se está montado
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: appTema.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: const Color(0xFFA9DBF4)),
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
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.asset("assets/logo.png", height: 40),
                    const Spacer(),
                    const ThemeToggleButton(),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.close,
                        color: appTema.textColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Seus Familiares",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: appTema.textColor,
                ),
              ),

              const SizedBox(height: 30),

              // Grid de perfis
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _perfisFilhos.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _perfisFilhos.length) {
                      return _buildPerfilExistente(
                        _perfisFilhos[index],
                        index,
                        appTema,
                      );
                    } else {
                      return _buildAdicionarPerfil(appTema);
                    }
                  },
                ),
              ),

              // Informação
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Toque em um perfil para gerenciá-lo',
                  style: TextStyle(
                    color: appTema.textSecondaryColor,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilExistente(
    Map<String, dynamic> perfil,
    int index,
    AppTema appTema,
  ) {
    return GestureDetector(
      onTap: () {
        _mostrarOpcoesPerfi(index, perfil, appTema);
      },
      child: Container(
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.grey[800]?.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    perfil['avatar'] ?? 'assets/avatar1.png',
                  ),
                ),
                // Badge de opções
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nome
            Text(
              perfil['apelido'] ?? 'Sem nome',
              style: TextStyle(
                color: appTema.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdicionarPerfil(AppTema appTema) {
    // Verifica se já atingiu o limite
    if (_perfisFilhos.length >= 4) {
      return Container(
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.grey[800]?.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 50,
              color: appTema.textSecondaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Limite\natingido',
              style: TextStyle(color: appTema.textSecondaryColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        await context.push('/avatar-filho');
        // Recarrega os perfis quando voltar
        _carregarPerfis();
      },
      child: Container(
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.grey[800]?.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA9DBF4), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFA9DBF4), width: 3),
              ),
              child: const Icon(Icons.add, size: 40, color: Color(0xFFA9DBF4)),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicionar\nFamiliar',
              style: TextStyle(
                color: appTema.textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
