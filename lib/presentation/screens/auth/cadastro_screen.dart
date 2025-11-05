import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _senhaController.text.trim(),
            );

        print(
          "Cadastro realizado com sucesso! Usuário: ${userCredential.user?.email}",
        );

        if (!mounted) return;
        context.go('/avatar');
      } on FirebaseAuthException catch (e) {
        String mensagem;
        if (e.code == 'weak-password') {
          mensagem = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
        } else if (e.code == 'email-already-in-use') {
          mensagem = 'Este e-mail já está cadastrado.';
        } else if (e.code == 'invalid-email') {
          mensagem = 'E-mail inválido.';
        } else {
          mensagem = 'Erro ao cadastrar: ${e.message}';
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "E-mail é obrigatório";
    }
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(valor.trim())) {
      return "E-mail inválido";
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "Senha é obrigatória";
    }
    if (valor.length < 6) {
      return "Senha deve ter pelo menos 6 caracteres";
    }
    return null;
  }

  String? _validarConfirmarSenha(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "Confirmação de senha é obrigatória";
    }
    if (valor != _senhaController.text) {
      return "As senhas não coincidem";
    }
    return null;
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
                    const ThemeToggleButton(showLogo: false), // ✅ CORRIGIDO
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/logo.png", width: 200),
                          const SizedBox(height: 16),
                          Text(
                            "Crie sua conta",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: appTema.textColor,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Campo E-mail
                          _buildTextField(
                            controller: _emailController,
                            hint: "E-mail",
                            validator: _validarEmail,
                          ),
                          const SizedBox(height: 16),

                          // Campo Senha
                          _buildTextField(
                            controller: _senhaController,
                            hint: "Senha",
                            obscure: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: _validarSenha,
                          ),
                          const SizedBox(height: 16),

                          // Campo Confirmar Senha
                          _buildTextField(
                            controller: _confirmarSenhaController,
                            hint: "Confirmar Senha",
                            obscure: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: _validarConfirmarSenha,
                          ),
                          const SizedBox(height: 30),

                          // Botão Cadastrar
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _cadastrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA9DBF4),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black.withValues(
                                  alpha: 77 / 255,
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
                                      "Cadastrar",
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botão Voltar
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      context.go('/options');
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA9DBF4),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black.withValues(
                                  alpha: 77 / 255,
                                ),
                              ),
                              child: const Text(
                                "Voltar",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      width: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 80 / 255),
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ),
    );
  }
}
