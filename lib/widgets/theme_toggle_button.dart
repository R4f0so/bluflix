import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_tema.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool showLogo; // ✅ Parâmetro para controlar se mostra a logo

  const ThemeToggleButton({
    super.key,
    this.showLogo = true, // Por padrão mostra a logo
  });

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    // Widget do botão (sempre o mesmo)
    final button = IconButton(
      onPressed: () => appTema.toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          appTema.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
          key: ValueKey(appTema.isDarkMode),
          color: appTema.isDarkMode ? Colors.amber : Colors.orange,
          size: 28,
        ),
      ),
      tooltip: appTema.isDarkMode ? 'Modo Claro' : 'Modo Escuro',
      splashRadius: 24,
      hoverColor: appTema.isDarkMode
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.05),
    );

    // Se showLogo for false, retorna apenas o botão
    if (!showLogo) {
      return button;
    }

    // Se showLogo for true, retorna logo + botão sem usar Spacer
    return Row(
      mainAxisSize:
          MainAxisSize.min, // ✅ IMPORTANTE: Evita unbounded constraints
      children: [
        Image.asset("assets/logo.png", height: 40),
        const SizedBox(width: 8), // Espaço fixo em vez de Spacer
        button,
      ],
    );
  }
}
