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
              // AppBar customizada
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.asset("assets/logo.png", height: 40),
                    const Spacer(),
                    const ThemeToggleButton(),
                    const SizedBox(width: 8),
                    // Botão de Configurações
                    IconButton(
                      onPressed: () {
                        context.push('/perfil-configs');
                      },
                      icon: Icon(
                        Icons.settings,
                        color: appTema.textColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saudação ao perfil pai
                      if (_perfilPai != null) ...[
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(
                                _perfilPai!['avatar'] ?? 'assets/avatar1.png',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, ${_perfilPai!['apelido']}!',
                                  style: TextStyle(
                                    color: appTema.textColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Gerencie os perfis familiares',
                                  style: TextStyle(
                                    color: appTema.textSecondaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Título da seção
                      Row(
                        children: [
                          Text(
                            'Perfis Familiares',
                            style: TextStyle(
                              color: appTema.textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA9DBF4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_perfisFilhos.length}/4',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Grade de perfis
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          // Cards dos perfis filhos existentes
                          ..._perfisFilhos.map(
                            (perfil) => _buildPerfilCard(perfil, appTema),
                          ),

                          // Botão adicionar perfil (se não atingiu o limite)
                          if (_perfisFilhos.length < 4)
                            _buildAdicionarPerfilCard(appTema),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Mensagem informativa
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: appTema.isDarkMode
                              ? Colors.grey[800]?.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: appTema.isDarkMode
                                ? Colors.white24
                                : Colors.black12,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFFA9DBF4),
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Os perfis familiares são protegidos por PIN. Apenas você pode acessar este gerenciamento.',
                                style: TextStyle(
                                  color: appTema.textSecondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilCard(Map<String, dynamic> perfil, AppTema appTema) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTema.isDarkMode
            ? Colors.grey[800]?.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Avatar (clicável para trocar de perfil)
          GestureDetector(
            onTap: () async {
              // Troca para o perfil filho
              final perfilProvider = Provider.of<PerfilProvider>(
                context,
                listen: false,
              );

              await perfilProvider.setPerfilAtivo(
                apelido: perfil['apelido'] ?? 'Sem nome',
                avatar: perfil['avatar'] ?? 'assets/avatar1.png',
                isPai: false,
              );

              if (!mounted) return;

              // Navega para o catálogo
              context.go('/catalogo');
            },
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                perfil['avatar'] ?? 'assets/avatar1.png',
              ),
            ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Botão de editar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _mostrarOpcoesEdicao(perfil, appTema);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFA9DBF4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                'Editar',
                style: TextStyle(color: appTema.textColor, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdicionarPerfilCard(AppTema appTema) {
    return GestureDetector(
      onTap: () async {
        // Navega e aguarda retorno
        await context.push('/adicionar-perfis');

        // Recarrega os perfis quando voltar
        if (mounted) {
          _carregarPerfis();
        }
      },
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.grey[800]?.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFA9DBF4),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFA9DBF4).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 48, color: Color(0xFFA9DBF4)),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicionar\nPerfil',
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

  // Mostra opções de edição do perfil filho
  void _mostrarOpcoesEdicao(Map<String, dynamic> perfil, AppTema appTema) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          color: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appTema.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(
                    perfil['avatar'] ?? 'assets/avatar1.png',
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  perfil['apelido'] ?? 'Sem nome',
                  style: TextStyle(
                    color: appTema.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Opção: Editar Preferências
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA9DBF4).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings, color: Color(0xFFA9DBF4)),
              ),
              title: Text(
                'Editar Preferências',
                style: TextStyle(
                  color: appTema.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Em desenvolvimento',
                style: TextStyle(
                  color: appTema.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                    backgroundColor: Color(0xFFA9DBF4),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Opção: Excluir Perfil
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: Text(
                'Excluir Perfil',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Requer PIN',
                style: TextStyle(
                  color: appTema.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _excluirPerfilFilho(perfil);
              },
            ),

            const SizedBox(height: 16),

            // Botão Cancelar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(bottomSheetContext),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: appTema.textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Excluir perfil filho
  Future<void> _excluirPerfilFilho(Map<String, dynamic> perfil) async {
    // Solicita PIN
    final pinVerificado = await VerificarPinDialog.verificar(context);

    if (!pinVerificado) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN incorreto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirma exclusão
    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _ConfirmarExclusaoPerfilDialog(
        apelido: perfil['apelido'] ?? 'Sem nome',
      ),
    );

    if (confirmar != true) return;

    // Exclui do Firestore
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          List<dynamic> perfisFilhos = userDoc.data()?['perfisFilhos'] ?? [];

          // Remove o perfil da lista
          perfisFilhos.removeWhere(
            (p) =>
                p['apelido'] == perfil['apelido'] &&
                p['avatar'] == perfil['avatar'],
          );

          // Atualiza no Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'perfisFilhos': perfisFilhos});

          if (!mounted) return;

          // Recarrega a lista
          _carregarPerfis();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// DIÁLOGO: CONFIRMAR EXCLUSÃO DE PERFIL FILHO
// ═══════════════════════════════════════════════════════════════

class _ConfirmarExclusaoPerfilDialog extends StatelessWidget {
  final String apelido;

  const _ConfirmarExclusaoPerfilDialog({required this.apelido});

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return AlertDialog(
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.5), width: 2),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
          const SizedBox(width: 12),
          Text(
            'Excluir Perfil',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deseja excluir o perfil "$apelido"?',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Esta ação não pode ser desfeita.',
            style: TextStyle(color: appTema.textSecondaryColor, fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: appTema.isDarkMode
                ? Colors.white70
                : Colors.black54,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}
