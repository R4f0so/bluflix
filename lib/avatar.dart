import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importado para navegação consistente
import 'apelido.dart'; // importe sua tela de apelido aqui
import 'login.dart'; // importe sua tela de login aqui

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAvatar;
  late AnimationController _controller;
  late Animation<double> _animation;

  // Lista de avatares (certifique-se de que esses assets existem)
  final List<String> avatars = [
    "assets/avatar1.png",
    "assets/avatar2.png",
    "assets/avatar3.png",
    "assets/avatar4.png",
    "assets/avatar5.png",
    "assets/avatar6.png",
    "assets/avatar7.png",
    "assets/avatar8.png",
  ];

  @override
  void initState() {
    super.initState();
    // Seleciona o primeiro avatar por padrão
    _selectedAvatar = avatars[0];

    // Configuração da animação de "flutuação" para o avatar selecionado
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectAvatar(String avatar) {
    setState(() {
      _selectedAvatar = avatar;
    });
  }

  // Utiliza context.go('/login') para navegar de volta à tela de login
  void _goBackToLogin() {
    context.go('/login');
  }

  // Widget construtor de avatar individual com animação e seleção
  Widget _avatarWidget(String avatar) {
    bool isSelected = _selectedAvatar == avatar;
    return GestureDetector(
      onTap: () => _selectAvatar(avatar),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Aplica o deslocamento vertical apenas se o avatar estiver selecionado
          double offset = isSelected ? -_animation.value : 0;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Container(
              padding: isSelected ? const EdgeInsets.all(4) : EdgeInsets.zero,
              decoration: isSelected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 3),
                    )
                  : null,
              child: ClipOval(
                child: Image.asset(
                  avatar,
                  width: 100, // Tamanho fixo para o avatar
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
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
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo
            Image.asset("assets/logo.png", width: 200),
            const SizedBox(height: 20),
            // Título
            const Text(
              "Escolha o seu avatar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Área do Grid de avatares (com scroll)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    // Gera as linhas de avatares (2 por linha)
                    children: List.generate((avatars.length / 2).ceil(), (
                      rowIndex,
                    ) {
                      int firstIndex = rowIndex * 2;
                      int secondIndex = firstIndex + 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _avatarWidget(avatars[firstIndex]),
                            if (secondIndex < avatars.length)
                              const SizedBox(width: 20),
                            if (secondIndex < avatars.length)
                              _avatarWidget(avatars[secondIndex]),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Botões de Ação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Voltar
                  ElevatedButton(
                    onPressed: _goBackToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Voltar"),
                  ),
                  // Botão Escolher esta imagem (Navega para ApelidoScreen)
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedAvatar != null) {
                        // Utiliza navegação padrão para passar o argumento
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ApelidoScreen(selectedAvatar: _selectedAvatar!),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA9DBF4),
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Escolher esta imagem"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
