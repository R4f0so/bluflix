import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _criarConta() {
    if (_formKey.currentState!.validate()) {
      // aqui você pode salvar dados ou chamar API
      debugPrint("Nome: ${_nomeController.text}");
      debugPrint("Email: ${_emailController.text}");
      debugPrint("Senha: ${_senhaController.text}");

      // navega para avatar
      context.go('/avatar');
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
                    "Cadastre sua conta",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nome de usuário
                  SizedBox(
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: TextFormField(
                          controller: _nomeController,
                          validator: (value) => _validarCampo(value, "Nome"),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withAlpha(80),
                            hintText: "Nome de Usuário",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // E-mail
                  SizedBox(
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: TextFormField(
                          controller: _emailController,
                          validator: _validarEmail,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withAlpha(80),
                            hintText: "E-mail",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Senha
                  SizedBox(
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: TextFormField(
                          controller: _senhaController,
                          obscureText: _obscurePassword,
                          validator: (value) => _validarCampo(value, "Senha"),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withAlpha(80),
                            hintText: "Senha",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirmar senha
                  SizedBox(
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: TextFormField(
                          controller: _confirmarSenhaController,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Confirme sua senha";
                            }
                            if (value.trim() != _senhaController.text.trim()) {
                              return "As senhas não são iguais";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withAlpha(80),
                            hintText: "Confirmar senha",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botão Criar conta
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _criarConta,
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
                        "Criar conta",
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
                        context.go(
                          '/options',
                        ); // volta explicitamente para Options
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

                  // Esqueceu a senha? Clique aqui!
                  RichText(
                    text: TextSpan(
                      text: "Esqueceu a senha? ",
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Clique aqui!",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // ação futura ao clicar
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Termos de uso
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Ao se cadastrar, você aceita os",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text:
                                " Termos de Uso e a Política de Privacidade do Bluflix",
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // ação de abrir link
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
