import 'package:flutter/material.dart';

class ApelidoScreen extends StatefulWidget {
  final String selectedAvatar;

  const ApelidoScreen({super.key, required this.selectedAvatar});

  @override
  State<ApelidoScreen> createState() => _ApelidoScreenState();
}

class _ApelidoScreenState extends State<ApelidoScreen> {
  final TextEditingController _apelidoController = TextEditingController();

  void _proceed() {
    String apelido = _apelidoController.text.trim();
    if (apelido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, insira um apelido")),
      );
      return;
    }

    debugPrint("Avatar: ${widget.selectedAvatar}, Apelido: $apelido");
    // Aqui você pode navegar para a próxima tela
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo no topo
              Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset("assets/logo.png", width: 200),
                  const SizedBox(height: 20),
                ],
              ),

              // Avatar escolhido
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(widget.selectedAvatar),
              ),
              const SizedBox(height: 20),

              // Campo de apelido
              TextField(
                controller: _apelidoController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Digite seu apelido",
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Volta para avatar.dart
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Voltar"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _proceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA9DBF4),
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Prosseguir"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
