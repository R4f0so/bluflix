import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'package:bluflix/data/services/pin_service.dart';

class CriaPinScreen extends StatefulWidget {
  final String apelido;
  final String avatar;

  const CriaPinScreen({super.key, required this.apelido, required this.avatar});

  @override
  State<CriaPinScreen> createState() => _CriaPinScreenState();
}

class _CriaPinScreenState extends State<CriaPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _isPinVisible = false;
  bool _isConfirmPinVisible = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _salvarPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    // Validações
    if (pin.isEmpty || confirmPin.isEmpty) {
      _mostrarErro('Por favor, preencha os dois campos');
      return;
    }

    if (pin.length != 4) {
      _mostrarErro('O PIN deve ter exatamente 4 dígitos');
      return;
    }

    if (pin != confirmPin) {
      _mostrarErro('Os PINs não coincidem. Tente novamente.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      print("════════════════════════════════");
      print("🔐 CRIANDO PIN DE SEGURANÇA");
      print("   Usuário: ${user.uid}");
      print("   Apelido: ${widget.apelido}");
      print("   Avatar: ${widget.avatar}");
      print("════════════════════════════════");

      // ✅ NOVO: Usa o PinService para hash seguro
      final pinService = PinService();
      final sucesso = await pinService.criarPinPerfilPai(pin);

      if (!sucesso) {
        throw Exception('Falha ao criar PIN');
      }

      // Salva o perfil pai (sem o PIN, que já foi salvo pelo PinService)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'apelido': widget.apelido,
        'avatar': widget.avatar,
        'perfisFilhos': [],
        'criadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("   ✅ Perfil pai e PIN salvos no Firestore");
      print("════════════════════════════════");

      if (!mounted) return;

      // Navega para a tela de gerenciamento de pais
      context.go('/gerenciamento-pais');
    } catch (e) {
      print("════════════════════════════════");
      print('❌ ERRO AO SALVAR PIN: $e');
      print("════════════════════════════════");

      if (!mounted) return;

      _mostrarErro('Erro ao criar PIN: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/logo.png", height: 40),
                      const ThemeToggleButton(showLogo: false),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(widget.avatar),
                  ),

                  const SizedBox(height: 16),

                  // Apelido
                  Text(
                    widget.apelido,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: appTema.textColor,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Título
                  Text(
                    "Crie seu PIN de segurança",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: appTema.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Descrição
                  Text(
                    "O PIN protegerá suas configurações e\ncontroles parentais",
                    style: TextStyle(
                      fontSize: 16,
                      color: appTema.textColor.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Campo PIN
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: !_isPinVisible,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      color: appTema.textColor,
                      fontSize: 18,
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "Digite seu PIN (4 dígitos)",
                      labelStyle: TextStyle(color: appTema.textColor),
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFA9DBF4),
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPinVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: appTema.textColor.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPinVisible = !_isPinVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Campo Confirmar PIN
                  TextField(
                    controller: _confirmPinController,
                    keyboardType: TextInputType.number,
                    obscureText: !_isConfirmPinVisible,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      color: appTema.textColor,
                      fontSize: 18,
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "Confirme seu PIN",
                      labelStyle: TextStyle(color: appTema.textColor),
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFA9DBF4),
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPinVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: appTema.textColor.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPinVisible = !_isConfirmPinVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Dica de segurança
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Escolha um PIN que você consiga lembrar, mas que seja difícil de adivinhar",
                            style: TextStyle(
                              color: appTema.textColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botão Criar PIN
                  SizedBox(
                    width: double.infinity,
                    height: 56,
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
                          : const Text(
                              "Criar PIN e Continuar",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
