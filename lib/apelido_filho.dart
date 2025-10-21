import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'widgets/theme_toggle_button.dart';

class ApelidoFilhoScreen extends StatefulWidget {
  final String selectedAvatar;
  const ApelidoFilhoScreen({super.key, required this.selectedAvatar});

  @override
  State<ApelidoFilhoScreen> createState() => _ApelidoFilhoScreenState();
}

class _ApelidoFilhoScreenState extends State<ApelidoFilhoScreen> {
  final TextEditingController _apelidoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfilFilho() async {
    final apelido = _apelidoController.text.trim();

    if (apelido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um apelido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Busca o documento do usuário
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Pega a lista atual de perfis filhos (ou cria uma vazia)
        List<dynamic> perfisFilhos = [];
        if (userDoc.exists) {
          perfisFilhos = userDoc.data()?['perfisFilhos'] ?? [];
        }

        // Verifica se já tem 4 perfis
        if (perfisFilhos.length >= 4) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Limite de 4 perfis atingido!'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Cria o novo perfil filho
        final novoPerfilFilho = {
          'apelido': apelido,
          'avatar': widget.selectedAvatar,
          'interesses': [],
          'criadoEm': Timestamp.now(),
        };

        // Adiciona o novo perfil à lista
        perfisFilhos.add(novoPerfilFilho);

        // Atualiza o Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'perfisFilhos': perfisFilhos});

        print("✅ Perfil filho salvo com sucesso!");

        if (!mounted) return;

        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil "$apelido" criado com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Volta para a tela de adicionar perfis
        context.pop(); // Volta da tela de apelido
        context.pop(); // Volta da tela de avatar
      }
    } catch (e) {
      print("❌ Erro ao salvar perfil filho: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.toString()}'),
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
                    const ThemeToggleButton(),
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
                  "Digite o apelido",
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
                    enabled: !_isLoading,
                    style: TextStyle(color: appTema.textColor, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Apelido do familiar",
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
                        onPressed: _isLoading ? null : _salvarPerfilFilho,
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
                            : const Text("Salvar"),
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
