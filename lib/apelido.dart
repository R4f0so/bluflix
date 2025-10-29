import 'widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';

class ApelidoScreen extends StatefulWidget {
  final String selectedAvatar;
  const ApelidoScreen({super.key, required this.selectedAvatar});

  @override
  State<ApelidoScreen> createState() => _ApelidoScreenState();
}

class _ApelidoScreenState extends State<ApelidoScreen> {
  final TextEditingController _apelidoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _salvarApelido() async {
    final apelido = _apelidoController.text.trim();

    if (apelido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um apelido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'apelido': apelido,
          'avatar': widget.selectedAvatar,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print("Dados salvos no Firestore com sucesso!");

        if (!mounted) return;
        // O usuário que acabou de se cadastrar é SEMPRE perfil pai
        context.push(
          '/criapin',
          extra: {
            'apelido': _apelidoController.text.trim(),
            'avatar': widget.selectedAvatar,
          },
        );
      }
    } catch (e) {
      print("Erro ao salvar dados: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // AppBar
                Row(
                  children: [
                    Image.asset("assets/logo.png", height: 40),
                    const Spacer(),
                    const ThemeToggleButton(showLogo: false), // ✅ CORRIGIDO
                  ],
                ),

                const Spacer(),

                // Avatar escolhido
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(widget.selectedAvatar),
                ),
                const SizedBox(height: 30),

                Text(
                  "Digite seu apelido",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appTema.textColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de apelido
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _apelidoController,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: appTema.textColor, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Seu apelido",
                      hintStyle: TextStyle(
                        color: appTema.textColor.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: appTema.isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Botões
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Voltar"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _salvarApelido,
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
                            : const Text("Prosseguir"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
