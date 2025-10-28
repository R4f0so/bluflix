import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'widgets/theme_toggle_button.dart';

class PerfilPaiConfigsScreen extends StatefulWidget {
  const PerfilPaiConfigsScreen({super.key});

  @override
  State<PerfilPaiConfigsScreen> createState() => _PerfilPaiConfigsScreenState();
}

class _PerfilPaiConfigsScreenState extends State<PerfilPaiConfigsScreen> {
  bool _isLoading = true;
  String _apelido = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (mounted) {
          setState(() {
            _apelido = userDoc.data()?['apelido'] ?? 'Usuário';
            _email = user.email ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _alterarSenha() async {
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _AlterarSenhaDialog(
        senhaAtualController: senhaAtualController,
        novaSenhaController: novaSenhaController,
        confirmarSenhaController: confirmarSenhaController,
      ),
    );

    if (resultado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _alterarApelido() async {
    final apelidoController = TextEditingController(text: _apelido);

    final novoApelido = await showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _AlterarApelidoDialog(apelidoController: apelidoController),
    );

    if (novoApelido != null && novoApelido.isNotEmpty && mounted) {
      setState(() {
        _apelido = novoApelido;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apelido alterado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _excluirConta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ConfirmarExclusaoDialog(),
    );

    if (confirmar == true && mounted) {
      // Solicita senha para confirmação final
      final senhaController = TextEditingController();

      final senhaConfirmada = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _ConfirmarSenhaDialog(
          senhaController: senhaController,
          email: _email,
        ),
      );

      if (senhaConfirmada == true && mounted) {
        // Exclui a conta
        setState(() => _isLoading = true);

        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Exclui documento do Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .delete();

            // Exclui conta do Firebase Auth
            await user.delete();

            if (mounted) {
              // Navega para options.dart
              context.go('/options');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conta excluída com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao excluir conta: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
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
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: appTema.textColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Configurações do Perfil',
                      style: TextStyle(
                        color: appTema.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const ThemeToggleButton(),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Card de informações
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apelido',
                              style: TextStyle(
                                color: appTema.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _apelido,
                              style: TextStyle(
                                color: appTema.textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'E-mail',
                              style: TextStyle(
                                color: appTema.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email,
                              style: TextStyle(
                                color: appTema.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Opções
                      _buildOpcaoCard(
                        appTema: appTema,
                        icone: Icons.edit,
                        titulo: 'Alterar Apelido',
                        subtitulo: 'Mude seu apelido de exibição',
                        onTap: _alterarApelido,
                      ),

                      const SizedBox(height: 16),

                      _buildOpcaoCard(
                        appTema: appTema,
                        icone: Icons.lock_outline,
                        titulo: 'Alterar Senha',
                        subtitulo: 'Mude a senha da sua conta',
                        onTap: _alterarSenha,
                      ),

                      const SizedBox(height: 32),

                      // Botão de Logout
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final router = GoRouter.of(context);

                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) =>
                                    _ConfirmarLogoutDialog(),
                              );

                              if (confirmar == true) {
                                await FirebaseAuth.instance.signOut();

                                if (!mounted) return;

                                // Usa router salvo antes da operação assíncrona
                                router.go('/options');
                              }
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Encerrar Sessão',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Zona de perigo
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red[700],
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Zona de Perigo',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _excluirConta,
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Excluir Conta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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

  Widget _buildOpcaoCard({
    required AppTema appTema,
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFA9DBF4).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: const Color(0xFFA9DBF4), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: appTema.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: appTema.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: appTema.textSecondaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIÁLOGO: ALTERAR SENHA
// ═══════════════════════════════════════════════════════════════

class _AlterarSenhaDialog extends StatefulWidget {
  final TextEditingController senhaAtualController;
  final TextEditingController novaSenhaController;
  final TextEditingController confirmarSenhaController;

  const _AlterarSenhaDialog({
    required this.senhaAtualController,
    required this.novaSenhaController,
    required this.confirmarSenhaController,
  });

  @override
  State<_AlterarSenhaDialog> createState() => _AlterarSenhaDialogState();
}

class _AlterarSenhaDialogState extends State<_AlterarSenhaDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureSenhaAtual = true;
  bool _obscureNovaSenha = true;
  bool _obscureConfirmarSenha = true;

  Future<void> _alterarSenha() async {
    final senhaAtual = widget.senhaAtualController.text.trim();
    final novaSenha = widget.novaSenhaController.text.trim();
    final confirmarSenha = widget.confirmarSenhaController.text.trim();

    if (senhaAtual.isEmpty || novaSenha.isEmpty || confirmarSenha.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha todos os campos';
      });
      return;
    }

    if (novaSenha.length < 6) {
      setState(() {
        _errorMessage = 'A nova senha deve ter no mínimo 6 caracteres';
      });
      return;
    }

    if (novaSenha != confirmarSenha) {
      setState(() {
        _errorMessage = 'As senhas não coincidem';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // Reautentica o usuário
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: senhaAtual,
        );

        await user.reauthenticateWithCredential(credential);

        // Atualiza a senha
        await user.updatePassword(novaSenha);

        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;
      if (e.code == 'wrong-password') {
        mensagem = 'Senha atual incorreta';
      } else if (e.code == 'weak-password') {
        mensagem = 'Senha muito fraca';
      } else {
        mensagem = 'Erro ao alterar senha: ${e.message}';
      }

      setState(() {
        _errorMessage = mensagem;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erro inesperado: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return AlertDialog(
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      title: Text(
        'Alterar Senha',
        style: TextStyle(
          color: appTema.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPasswordField(
              appTema: appTema,
              controller: widget.senhaAtualController,
              label: 'Senha Atual',
              obscure: _obscureSenhaAtual,
              onToggle: () =>
                  setState(() => _obscureSenhaAtual = !_obscureSenhaAtual),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              appTema: appTema,
              controller: widget.novaSenhaController,
              label: 'Nova Senha',
              obscure: _obscureNovaSenha,
              onToggle: () =>
                  setState(() => _obscureNovaSenha = !_obscureNovaSenha),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              appTema: appTema,
              controller: widget.confirmarSenhaController,
              label: 'Confirmar Nova Senha',
              obscure: _obscureConfirmarSenha,
              onToggle: () => setState(
                () => _obscureConfirmarSenha = !_obscureConfirmarSenha,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Color(0xFFA9DBF4)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: appTema.isDarkMode
                ? Colors.white70
                : Colors.black54,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _alterarSenha,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA9DBF4),
            foregroundColor: Colors.black,
          ),
          child: const Text('Alterar'),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required AppTema appTema,
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: appTema.textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: appTema.textSecondaryColor),
        filled: true,
        fillColor: appTema.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: appTema.textSecondaryColor,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIÁLOGO: ALTERAR APELIDO
// ═══════════════════════════════════════════════════════════════

class _AlterarApelidoDialog extends StatefulWidget {
  final TextEditingController apelidoController;

  const _AlterarApelidoDialog({required this.apelidoController});

  @override
  State<_AlterarApelidoDialog> createState() => _AlterarApelidoDialogState();
}

class _AlterarApelidoDialogState extends State<_AlterarApelidoDialog> {
  bool _isLoading = false;

  Future<void> _salvarApelido() async {
    final novoApelido = widget.apelidoController.text.trim();

    if (novoApelido.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'apelido': novoApelido});

        if (!mounted) return;
        Navigator.of(context).pop(novoApelido);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar apelido: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return AlertDialog(
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      title: Text(
        'Alterar Apelido',
        style: TextStyle(
          color: appTema.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.apelidoController,
            autofocus: true,
            style: TextStyle(color: appTema.textColor),
            decoration: InputDecoration(
              labelText: 'Novo Apelido',
              labelStyle: TextStyle(color: appTema.textSecondaryColor),
              filled: true,
              fillColor: appTema.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Color(0xFFA9DBF4)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(null),
          style: TextButton.styleFrom(
            foregroundColor: appTema.isDarkMode
                ? Colors.white70
                : Colors.black54,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvarApelido,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA9DBF4),
            foregroundColor: Colors.black,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIÁLOGO: CONFIRMAR LOGOUT
// ═══════════════════════════════════════════════════════════════

class _ConfirmarLogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return AlertDialog(
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      title: Row(
        children: [
          Icon(Icons.logout, color: Colors.orange[700], size: 28),
          const SizedBox(width: 12),
          Text(
            'Encerrar Sessão',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        'Tem certeza que deseja encerrar sua sessão?',
        style: TextStyle(color: appTema.textSecondaryColor, fontSize: 16),
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
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Encerrar Sessão'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIÁLOGO: CONFIRMAR EXCLUSÃO
// ═══════════════════════════════════════════════════════════════

class _ConfirmarExclusaoDialog extends StatelessWidget {
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
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 32),
          const SizedBox(width: 12),
          Text(
            'Excluir Conta',
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
            'Esta ação é IRREVERSÍVEL!',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ao excluir sua conta:',
            style: TextStyle(color: appTema.textColor, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '• Todos os seus dados serão perdidos\n'
            '• Todos os perfis familiares serão excluídos\n'
            '• Não será possível recuperar a conta',
            style: TextStyle(
              color: appTema.textSecondaryColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Você tem certeza?',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
          child: const Text('Sim, estou ciente'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIÁLOGO: CONFIRMAR SENHA PARA EXCLUSÃO
// ═══════════════════════════════════════════════════════════════

class _ConfirmarSenhaDialog extends StatefulWidget {
  final TextEditingController senhaController;
  final String email;

  const _ConfirmarSenhaDialog({
    required this.senhaController,
    required this.email,
  });

  @override
  State<_ConfirmarSenhaDialog> createState() => _ConfirmarSenhaDialogState();
}

class _ConfirmarSenhaDialogState extends State<_ConfirmarSenhaDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureSenha = true;

  Future<void> _confirmarSenha() async {
    final senha = widget.senhaController.text.trim();

    if (senha.isEmpty) {
      setState(() {
        _errorMessage = 'Digite sua senha';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reautentica o usuário
        final credential = EmailAuthProvider.credential(
          email: widget.email,
          password: senha,
        );

        await user.reauthenticateWithCredential(credential);

        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;
      if (e.code == 'wrong-password') {
        mensagem = 'Senha incorreta';
      } else {
        mensagem = 'Erro: ${e.message}';
      }

      setState(() {
        _errorMessage = mensagem;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erro inesperado: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return AlertDialog(
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.5), width: 2),
      ),
      title: Text(
        'Digite sua senha',
        style: TextStyle(
          color: appTema.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Para confirmar a exclusão da conta, digite sua senha:',
            style: TextStyle(color: appTema.textSecondaryColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.senhaController,
            obscureText: _obscureSenha,
            autofocus: true,
            style: TextStyle(color: appTema.textColor),
            decoration: InputDecoration(
              labelText: 'Senha',
              labelStyle: TextStyle(color: appTema.textSecondaryColor),
              filled: true,
              fillColor: appTema.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSenha ? Icons.visibility_off : Icons.visibility,
                  color: appTema.textSecondaryColor,
                ),
                onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.red),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: appTema.isDarkMode
                ? Colors.white70
                : Colors.black54,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _confirmarSenha,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar Exclusão'),
        ),
      ],
    );
  }
}
