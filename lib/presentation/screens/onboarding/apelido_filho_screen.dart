import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';

class ApelidoFilhoScreen extends StatefulWidget {
  final String selectedAvatar;
  const ApelidoFilhoScreen({super.key, required this.selectedAvatar});

  @override
  State<ApelidoFilhoScreen> createState() => _ApelidoFilhoScreenState();
}

class _ApelidoFilhoScreenState extends State<ApelidoFilhoScreen> {
  final TextEditingController _apelidoController = TextEditingController();

  @override
  void dispose() {
    _apelidoController.dispose();
    super.dispose();
  }

  void _navegarParaPreferencias() {
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

    // Navega para a tela de preferências passando os dados
    context.push(
      '/preferencias-filho',
      extra: {'apelido': apelido, 'avatar': widget.selectedAvatar},
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.asset("assets/logo.png", height: 40),
                      const Spacer(),
                      const ThemeToggleButton(showLogo: false),
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
                        onPressed: () => context.pop(),
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
                        onPressed: _navegarParaPreferencias,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA9DBF4),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Próximo"),
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
