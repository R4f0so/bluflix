import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';

class ThemeToggleButton extends StatefulWidget {
  final bool showLogo;

  const ThemeToggleButton({super.key, this.showLogo = true});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurveTween(curve: Curves.easeInOut).animate(_controller));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleTheme() async {
    final appTema = Provider.of<AppTema>(context, listen: false);

    // Inicia a animação
    _controller.forward(from: 0);

    // Aguarda um pouco antes de trocar o tema (para sincronizar com a animação)
    await Future.delayed(const Duration(milliseconds: 200));

    // Troca o tema
    await appTema.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159, // 180 graus
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: _controller.isAnimating
                    ? [
                        BoxShadow(
                          color:
                              (appTema.isDarkMode
                                      ? Colors.yellow
                                      : Colors.orange)
                                  .withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: IconButton(
                // ✅ CORRIGIDO: Sol no claro, Lua (amarela) no escuro
                icon: Icon(
                  appTema.isDarkMode
                      ? Icons
                            .nightlight_round // 🌙 Lua amarela para modo escuro
                      : Icons.wb_sunny, // ☀️ Sol para modo claro
                  color: appTema.isDarkMode
                      ? Colors
                            .yellow // Lua amarela
                      : Colors.orange, // Sol laranja/amarelo
                  size: 28,
                ),
                onPressed: _toggleTheme,
                tooltip: appTema.isDarkMode
                    ? 'Alternar para Tema Claro'
                    : 'Alternar para Tema Escuro',
              ),
            ),
          ),
        );
      },
    );
  }
}
