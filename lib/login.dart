import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true; // controla se a senha está oculta

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/logo.png", width: 200),
                const SizedBox(height: 40),

                // Campo de email
                SizedBox(
                  width: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withAlpha(80),
                          hintText: "Email ou usuário",
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

                // Campo de senha
                SizedBox(
                  width: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: TextField(
                        obscureText: _obscurePassword,
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
                const SizedBox(height: 30),

                // Botão de entrar
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // exemplo: depois de logar, vai para home
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
                    child: const Text("Entrar", style: TextStyle(fontSize: 18)),
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
                    child: const Text("Voltar", style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 24),

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

                // Logos Google e Facebook lado a lado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/google.png", width: 50, height: 50),
                    const SizedBox(width: 20),
                    Image.asset("assets/facebook.png", width: 50, height: 50),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
