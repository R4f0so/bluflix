import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_tema.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return IconButton(
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
          ? Colors.amber.withValues(alpha: 0.2)
          : Colors.orange.withValues(alpha: 0.2),
    );
  }
}
