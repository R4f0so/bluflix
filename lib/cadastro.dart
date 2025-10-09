import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import necessário para Firestore

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

  // Mantendo o controle de obscurecimento simplificado do segundo código
  bool _obscurePassword = true; 
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // Função para criar conta no Firebase com persistência no Firestore
  Future<void> _criarConta() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // 1. Cria o usuário no Firebase Auth
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );

        final user = cred.user;
        if (user != null) {
          // 2. Salva os dados iniciais do usuário no Firestore (como no código original)
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': user.email,
            'apelido': null,
            'avatar': null,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 3. Navega para a tela de avatar
          if (!mounted) return;
          context.go('/avatar');
        }
      } on FirebaseAuthException catch (e) {
        String mensagem;
        if (e.code == 'weak-password') {
          mensagem = 'A senha é muito fraca (mínimo 6 caracteres).';
        } else if (e.code == 'email-already-in-use') {
          mensagem = 'Este e-mail já está em uso.';
        } else {
          mensagem = 'Erro ao criar conta: ${e.message}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(mensagem)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro inesperado: ${e.toString()}')));
        }
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
    // Regex mais robusta para e-mail
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(valor.trim())) {
      return "E-mail inválido";
    }
    return null;
  }

  // Widget para construir os campos de texto com efeito blur (layout da versão 2)
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
                  // Logo (Layout da Versão 2)
                  Image.asset("assets/logo.png", width: 200),
                  const SizedBox(height: 16),
                  
                  // Título
                  const Text(
                    "Cadastre sua conta",
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
                    // Usa o estado de obscurecimento da Versão 2
                    obscure: _obscurePassword, 
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          // Toggle do obscurecimento para ambas as senhas (padrão da Versão 2)
                          _obscurePassword = !_obscurePassword; 
                        });
                      },
                    ),
                    validator: (v) {
                       // Usa validação de campo obrigatório e checa o tamanho mínimo 
                       if (v == null || v.trim().isEmpty) {
                           return "Senha é obrigatória";
                       }
                       if (v.trim().length < 6) {
                           return "A senha deve ter pelo menos 6 caracteres.";
                       }
                       return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirmar senha
                  _buildTextField(
                    controller: _confirmarSenhaController,
                    hint: "Confirmar senha",
                    // Usa o mesmo estado de obscurecimento da Versão 2
                    obscure: _obscurePassword, 
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          // Toggle do obscurecimento para ambas as senhas (padrão da Versão 2)
                          _obscurePassword = !_obscurePassword; 
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Confirme sua senha";
                      }
                      if (value.trim() != _senhaController.text.trim()) {
                        return "As senhas não são iguais";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Botão Criar conta
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _criarConta,
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
                              "Criar conta",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão de voltar → vai para OptionsScreen (Layout da Versão 2)
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
                  const SizedBox(height: 16),

                  // Termos de uso e RichText (Layout da Versão 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Ao se cadastrar, você aceita os ",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text:
                                "Termos de Uso e a Política de Privacidade do Bluflix.",
                            style: const TextStyle(
                              color: Color(0xFF003366), // azul escuro
                              decoration: TextDecoration.none,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Ação ao clicar (você pode implementar a navegação para a página de termos)
                                print("Termos de Uso clicado");
                              },
                          ),
                        ],
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