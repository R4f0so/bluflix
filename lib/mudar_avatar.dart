import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';

class MudarAvatarScreen extends StatefulWidget {
  const MudarAvatarScreen({super.key});

  @override
  State<MudarAvatarScreen> createState() => _MudarAvatarScreenState();
}

class _MudarAvatarScreenState extends State<MudarAvatarScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAvatar;
  bool _isLoading = false;
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

    // Pega o avatar atual
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    _selectedAvatar = perfilProvider.perfilAtivoAvatar ?? avatars[0];

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

  Future<void> _salvarAvatar() async {
    if (_selectedAvatar == null) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );

      // Verifica se é perfil pai ou filho
      if (perfilProvider.isPerfilPai) {
        // Atualiza avatar do perfil pai
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'avatar': _selectedAvatar});

        // Atualiza no provider
        await perfilProvider.setPerfilAtivo(
          apelido: perfilProvider.perfilAtivoApelido!,
          avatar: _selectedAvatar!,
          isPai: true,
        );
      } else {
        // Atualiza avatar do perfil filho
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          List<dynamic> perfisFilhos = data?['perfisFilhos'] ?? [];

          // Encontra o perfil filho atual e atualiza
          for (int i = 0; i < perfisFilhos.length; i++) {
            if (perfisFilhos[i]['apelido'] ==
                perfilProvider.perfilAtivoApelido) {
              perfisFilhos[i]['avatar'] = _selectedAvatar;
              break;
            }
          }

          // Salva no Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'perfisFilhos': perfisFilhos});

          // Atualiza no provider
          await perfilProvider.setPerfilAtivo(
            apelido: perfilProvider.perfilAtivoApelido!,
            avatar: _selectedAvatar!,
            isPai: false,
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar atualizado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      context.pop();
    } catch (e) {
      print('Erro ao salvar avatar: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.asset("assets/logo.png", height: 40),
                    const Spacer(),
                    const ThemeToggleButton(showLogo: false), // ✅ SEM logo
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

              const SizedBox(height: 20),

              Text(
                "Escolha seu novo avatar",
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

              // Botão Salvar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvarAvatar,
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
                        : const Text(
                            "Salvar Avatar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
}
