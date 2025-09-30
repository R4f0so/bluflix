import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // necessário para usar context.go

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/morning_background.png",
            ), // mesmo fundo da Home
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // centraliza verticalmente
            children: [
              Image.asset(
                "assets/logo.png",
                width: 200, // tamanho do logo
              ),
              const SizedBox(height: 40), // espaço entre logo e botão
              // Botão de login
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/login'); // go_router substitui Navigator
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA9DBF4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black.withAlpha(50),
                    elevation: 4,
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 16), // espaço entre os botões
              // Botão de criar conta
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/cadastro'); // go_router substitui Navigator
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA9DBF4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.black.withAlpha(50),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Criar conta",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
