// lib/gerenciamento_pais.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';
import 'pin_verification.dart';

class GerenciamentoPaisScreen extends StatefulWidget {
  const GerenciamentoPaisScreen({super.key});

  @override
  State<GerenciamentoPaisScreen> createState() =>
      _GerenciamentoPaisScreenState();
}

class _GerenciamentoPaisScreenState extends State<GerenciamentoPaisScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _perfisFilhos = [];
  Map<String, dynamic>? _perfilPai;

  @override
  void initState() {
    super.initState();
    _carregarPerfis();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarPerfis();
  }

  Future<void> _carregarPerfis() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();

          if (mounted) {
            setState(() {
              _perfilPai = {
                'apelido': data?['apelido'] ?? 'Usuário',
                'avatar': data?['avatar'] ?? 'assets/avatar1.png',
              };

              final perfis = data?['perfisFilhos'] as List<dynamic>? ?? [];
              _perfisFilhos = perfis
                  .map((p) => Map<String, dynamic>.from(p))
                  .toList();
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar perfis: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _trocarParaPerfilFilho(Map<String, dynamic> perfil) async {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    await perfilProvider.setPerfilAtivo(
      apelido: perfil['apelido'],
      avatar: perfil['avatar'],
      isPai: false,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trocado para perfil ${perfil['apelido']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    context.go('/catalogo');
  }

  // ✨ NOVA FUNÇÃO: Mostrar opções de edição
  void _mostrarOpcoesEdicao(
    int index,
    Map<String, dynamic> perfil,
    AppTema appTema,
  ) {
    final apelido = perfil['apelido'] ?? 'Perfil';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle do modal
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header com avatar e nome
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage(
                          perfil['avatar'] ?? 'assets/avatar1.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apelido,
                              style: TextStyle(
                                color: appTema.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Perfil Filho',
                              style: TextStyle(
                                color: appTema.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Opção: Editar Preferências
                ListTile(
                  leading: Icon(Icons.tune, color: appTema.textColor, size: 24),
                  title: Text(
                    'Editar Preferências',
                    style: TextStyle(
                      color: appTema.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Ajustar interesses e configurações',
                    style: TextStyle(
                      color: appTema.textSecondaryColor,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                    if (mounted) {
                      // TODO: Implementar tela de preferências
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Função em desenvolvimento...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),

                const Divider(height: 1),

                // Opção: Excluir Perfil (em vermelho)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 24,
                  ),
                  title: const Text(
                    'Excluir Perfil',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Remover permanentemente este perfil',
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                    if (mounted) {
                      _iniciarExclusaoPerfil(index, perfil);
                    }
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

  // ✨ NOVA FUNÇÃO: Iniciar processo de exclusão
  Future<void> _iniciarExclusaoPerfil(
    int index,
    Map<String, dynamic> perfil,
  ) async {
    final apelido = perfil['apelido'] ?? 'este perfil';

    if (!mounted) return;

    // Passo 1: Verificar PIN
    final pinVerificado = await VerificarPinDialog.verificar(context);

    if (!pinVerificado) {
      return; // Usuário cancelou ou PIN incorreto
    }

    if (!mounted) return;

    // Passo 2: Confirmar exclusão
    final appTema = Provider.of<AppTema>(context, listen: false);
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.5), width: 2),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirmar Exclusão',
                style: TextStyle(
                  color: appTema.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja realmente excluir o perfil "$apelido"?',
              style: TextStyle(color: appTema.textColor, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita.',
                      style: TextStyle(color: appTema.textColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: appTema.textSecondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _excluirPerfil(index, apelido);
    }
  }

  // ✨ NOVA FUNÇÃO: Excluir perfil do Firestore
  Future<void> _excluirPerfil(int index, String apelidoExcluido) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      print("════════════════════════════════");
      print("🗑️ EXCLUINDO PERFIL FILHO");
      print("   Índice: $index");
      print("   Apelido: $apelidoExcluido");
      print("════════════════════════════════");

      // Remove da lista local
      _perfisFilhos.removeAt(index);

      // Atualiza no Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'perfisFilhos': _perfisFilhos},
      );

      print("   ✅ Perfil excluído com sucesso!");
      print("════════════════════════════════");

      if (!mounted) return;

      // Verifica se o perfil excluído era o ativo
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );

      if (perfilProvider.perfilAtivoApelido == apelidoExcluido) {
        // Se o perfil excluído era o ativo, volta para o perfil pai
        await perfilProvider.setPerfilAtivo(
          apelido: _perfilPai?['apelido'] ?? 'Usuário',
          avatar: _perfilPai?['avatar'] ?? 'assets/avatar1.png',
          isPai: true,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil excluído! Voltando para o perfil principal.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
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

      // Atualiza a UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("════════════════════════════════");
      print("❌ ERRO AO EXCLUIR PERFIL: $e");
      print("════════════════════════════════");

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

    final bool limiteAtingido = _perfisFilhos.length >= 4;

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
                    const ThemeToggleButton(showLogo: false),
                    IconButton(
                      onPressed: () async {
                        await context.push('/perfil-configs');
                        if (mounted) {
                          _carregarPerfis();
                        }
                      },
                      icon: Icon(
                        Icons.settings,
                        color: appTema.textColor,
                        size: 28,
                      ),
                      tooltip: 'Configurações',
                    ),
                  ],
                ),
              ),

              // Informações do Perfil Pai
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        _perfilPai?['avatar'] ?? 'assets/avatar1.png',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _perfilPai?['apelido'] ?? 'Usuário',
                      style: TextStyle(
                        color: appTema.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Perfil Pai',
                      style: TextStyle(
                        color: appTema.textColor.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Título da seção de perfis filhos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      'Perfis Filhos',
                      style: TextStyle(
                        color: appTema.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${_perfisFilhos.length}/4)',
                      style: TextStyle(
                        color: appTema.textColor.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lista de perfis filhos
              Expanded(
                child: _perfisFilhos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: appTema.textColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum perfil filho criado',
                              style: TextStyle(
                                color: appTema.textColor.withValues(alpha: 0.6),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toque no + para adicionar',
                              style: TextStyle(
                                color: appTema.textColor.withValues(alpha: 0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            ..._perfisFilhos.asMap().entries.map(
                              (entry) => _buildPerfilCard(
                                entry.value,
                                entry.key,
                                appTema,
                              ),
                            ),
                            if (!limiteAtingido)
                              GestureDetector(
                                onTap: () async {
                                  await context.push('/adicionar-perfis');
                                  if (mounted) {
                                    _carregarPerfis();
                                  }
                                },
                                child: _buildAdicionarCard(appTema),
                              ),
                          ],
                        ),
                      ),
              ),

              // Botão adicionar (quando não há perfis)
              if (_perfisFilhos.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await context.push('/adicionar-perfis');
                        if (mounted) {
                          _carregarPerfis();
                        }
                      },
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text(
                        'Adicionar Perfil',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA9DBF4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  // ✨ ATUALIZADO: Card com botão "Editar"
  Widget _buildPerfilCard(
    Map<String, dynamic> perfil,
    int index,
    AppTema appTema,
  ) {
    return GestureDetector(
      onTap: () => _trocarParaPerfilFilho(perfil),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                perfil['avatar'] ?? 'assets/avatar1.png',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              perfil['apelido'] ?? 'Perfil',
              style: TextStyle(
                color: appTema.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                _mostrarOpcoesEdicao(index, perfil, appTema);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: appTema.textColor,
                side: BorderSide(
                  color: appTema.textColor.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Editar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdicionarCard(AppTema appTema) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: appTema.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA9DBF4),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle_outline,
            size: 60,
            color: Color(0xFFA9DBF4),
          ),
          const SizedBox(height: 12),
          Text(
            'Adicionar\nPerfil',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
