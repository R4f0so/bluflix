import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';

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

        print(
          "Login realizado com sucesso! Usuário: ${userCredential.user?.email}",
        );

        if (!mounted) return;

        // ✅ Carrega tema
        final appTema = Provider.of<AppTema>(context, listen: false);
        await appTema.loadThemeFromFirestore();

        final user = userCredential.user;
        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!mounted) return;

          if (!userDoc.exists) {
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

            if (!mounted) return;
            context.go('/avatar');
            return;
          }

          final userData = userDoc.data();

          if (userData?['apelido'] == null || userData?['avatar'] == null) {
            context.go('/avatar');
          } else {
            // ✅ NOVO: Verificar se é admin ANTES de redirecionar
            final tipoUsuario = userData?['tipoUsuario'] ?? '';
            final isAdmin = tipoUsuario == 'admin';

            print("🔍 Verificando tipo de usuário...");
            print("   tipoUsuario: $tipoUsuario");
            print("   É admin? $isAdmin");

            // Configurar perfil ativo
            final perfilProvider = Provider.of<PerfilProvider>(
              context,
              listen: false,
            );

            if (perfilProvider.perfilAtivoApelido == null) {
              await perfilProvider.setPerfilAtivo(
                apelido: userData?['apelido'] ?? 'Usuário',
                avatar: userData?['avatar'] ?? 'assets/avatar1.png',
                isPai: true,
              );
            }

            if (!mounted) return;

            // ✅ NOVO: Redirecionamento baseado em admin
            if (isAdmin) {
              print("🎬 ADMIN - Redirecionando para /gerenciamento-admin");
              context.go('/gerenciamento-admin');
            } else if (perfilProvider.isPerfilPai) {
              print("👨 Perfil PAI - Redirecionando para /gerenciamento-pais");
              context.go('/gerenciamento-pais');
            } else {
              print("👶 Perfil FILHO - Redirecionando para /catalogo");
              context.go('/catalogo');
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        String mensagem;
        if (e.code == 'user-not-found') {
          mensagem = 'Nenhum usuário encontrado com esse email.';
        } else if (e.code == 'wrong-password') {
          mensagem = 'Senha incorreta.';
        } else if (e.code == 'invalid-credential') {
          mensagem = 'Credenciais inválidas. Verifique email e senha.';
        } else if (e.code == 'invalid-email') {
          mensagem = 'E-mail inválido.';
        } else if (e.code == 'user-disabled') {
          mensagem = 'Esta conta foi desabilitada.';
        } else if (e.code == 'too-many-requests') {
          mensagem = 'Muitas tentativas. Tente novamente mais tarde.';
        } else {
          mensagem = 'Erro ao fazer login: ${e.message}';
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Spacer(),
                    const ThemeToggleButton(showLogo: false),
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
                            "Faça login na sua conta",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: appTema.textColor,
                            ),
                          ),
                          const SizedBox(height: 30),

                          _buildTextField(
                            controller: _emailController,
                            hint: "E-mail",
                            validator: _validarEmail,
                          ),
                          const SizedBox(height: 16),

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
                          const SizedBox(height: 30),

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
                                      "Entrar",
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

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
