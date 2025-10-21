import 'widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';

class AvatarFilhoScreen extends StatefulWidget {
  const AvatarFilhoScreen({super.key});

  @override
  State<AvatarFilhoScreen> createState() => _AvatarFilhoScreenState();
}

class _AvatarFilhoScreenState extends State<AvatarFilhoScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAvatar;
  late AnimationController _controller;
  late Animation<double> _animation;

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
    _selectedAvatar = avatars[0];

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
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.asset("assets/logo.png", height: 40),
                    const Spacer(),
                    const ThemeToggleButton(), 
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Escolha o avatar",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: appTema.textColor,
                ),
              ),

              const SizedBox(height: 30),

              // Grid de avatares
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = avatars[index];
                    final isSelected = _selectedAvatar == avatar;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                        });
                      },
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          double offset = isSelected ? -_animation.value : 0;
                          return Transform.translate(
                            offset: Offset(0, offset),
                            child: Container(
                              padding: isSelected
                                  ? const EdgeInsets.all(4)
                                  : null,
                              decoration: isSelected
                                  ? BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFA9DBF4),
                                        width: 4,
                                      ),
                                    )
                                  : null,
                              child: ClipOval(
                                child: Image.asset(avatar, fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Botões
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
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
                        onPressed: () {
                          context.push(
                            '/apelido-filho',
                            extra: _selectedAvatar,
                          );
                        },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
