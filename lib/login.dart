import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _senhaController.text.trim(),
            );

        // Login bem-sucedido → print no console
        print(
          "Login realizado com sucesso! Usuário: ${userCredential.user?.email}",
        );

        // Verifica se ainda está montado antes de usar context
        if (!mounted) return;
        context.go('/options');
      } on FirebaseAuthException catch (e) {
        String mensagem;
        if (e.code == 'user-not-found') {
          mensagem = 'Nenhum usuário encontrado com esse email.';
        } else if (e.code == 'wrong-password') {
          mensagem = 'Senha incorreta.';
        } else {
          mensagem = 'Erro ao fazer login: ${e.message}';
        }

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensagem)));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validarCampo(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return "$campo é obrigatório";
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/morning_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/logo.png", width: 200),
                  const SizedBox(height: 16),
                  const Text(
                    "Faça login na sua conta",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // E-mail
                  _buildTextField(
                    controller: _emailController,
                    hint: "E-mail",
                    validator: _validarEmail,
                  ),
                  const SizedBox(height: 16),

                  // Senha
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
                    validator: (v) => _validarCampo(v, "Senha"),
                  ),
                  const SizedBox(height: 30),

                  // Botão Entrar
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA9DBF4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withAlpha(77),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Entrar",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão de voltar → vai para OptionsScreen
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/options');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA9DBF4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withAlpha(77),
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
              fillColor: Colors.white.withAlpha(80),
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
