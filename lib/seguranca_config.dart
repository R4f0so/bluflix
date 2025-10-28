import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_tema.dart';
import 'widgets/theme_toggle_button.dart';

class SegurancaConfigScreen extends StatefulWidget {
  const SegurancaConfigScreen({super.key});

  @override
  State<SegurancaConfigScreen> createState() => _SegurancaConfigScreenState();
}

class _SegurancaConfigScreenState extends State<SegurancaConfigScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  String? _pinAtual;

  @override
  void initState() {
    super.initState();
    _carregarPinAtual();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _carregarPinAtual() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _pinAtual = userDoc.data()?['pin'];
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar PIN: $e');
    }
  }

  Future<void> _salvarPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.isEmpty || confirmPin.isEmpty) {
      _mostrarErro('Por favor, preencha todos os campos');
      return;
    }

    if (pin.length != 4) {
      _mostrarErro('O PIN deve ter exatamente 4 dígitos');
      return;
    }

    if (pin != confirmPin) {
      _mostrarErro('Os PINs não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'pin': pin});

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN configurado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop();
      }
    } catch (e) {
      _mostrarErro('Erro ao salvar PIN: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removerPin() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final appTema = Provider.of<AppTema>(context, listen: false);
        return AlertDialog(
          backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text(
            'Remover PIN',
            style: TextStyle(color: appTema.textColor),
          ),
          content: Text(
            'Deseja realmente remover o PIN de segurança?',
            style: TextStyle(color: appTema.textSecondaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'pin': FieldValue.delete()});

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN removido com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          context.pop();
        }
      } catch (e) {
        _mostrarErro('Erro ao remover PIN: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

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
                    const ThemeToggleButton(showLogo: false), // ✅ SEM logo
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

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: const Color(0xFFA9DBF4),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        _pinAtual == null
                            ? 'Configurar PIN de Segurança'
                            : 'Alterar PIN de Segurança',
                        style: TextStyle(
                          color: appTema.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Use um PIN de 4 dígitos para proteger ações sensíveis',
                        style: TextStyle(
                          color: appTema.textSecondaryColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Campo PIN
                      _buildPinField(
                        controller: _pinController,
                        label: 'Digite o PIN',
                        appTema: appTema,
                      ),

                      const SizedBox(height: 20),

                      // Campo Confirmar PIN
                      _buildPinField(
                        controller: _confirmPinController,
                        label: 'Confirme o PIN',
                        appTema: appTema,
                      ),

                      const SizedBox(height: 40),

                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _salvarPin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA9DBF4),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _pinAtual == null
                                      ? 'Configurar PIN'
                                      : 'Alterar PIN',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Botão Remover (só aparece se já tiver PIN)
                      if (_pinAtual != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _removerPin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Remover PIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required AppTema appTema,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 4,
      obscureText: true,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: appTema.textColor,
        fontSize: 24,
        letterSpacing: 12,
        fontWeight: FontWeight.bold,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: appTema.textSecondaryColor),
        filled: true,
        fillColor: appTema.isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterText: '',
      ),
    );
  }
}
