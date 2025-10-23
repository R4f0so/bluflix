import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'widgets/theme_toggle_button.dart';

class TemaConfigScreen extends StatelessWidget {
  const TemaConfigScreen({super.key});

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

              // Título
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Preferência de Tema',
                  style: TextStyle(
                    color: appTema.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Opção Claro
              _buildTemaCard(
                context: context,
                appTema: appTema,
                isDark: false,
                isSelected: !appTema.isDarkMode,
              ),

              const SizedBox(height: 20),

              // Opção Escuro
              _buildTemaCard(
                context: context,
                appTema: appTema,
                isDark: true,
                isSelected: appTema.isDarkMode,
              ),

              const Spacer(),

              // Informação
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Sua preferência será salva automaticamente',
                  style: TextStyle(
                    color: appTema.textSecondaryColor,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemaCard({
    required BuildContext context,
    required AppTema appTema,
    required bool isDark,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (isDark != appTema.isDarkMode) {
          appTema.toggleTheme(); // ✅ Remove o await

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tema ${isDark ? "escuro" : "claro"} ativado!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[900]?.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA9DBF4)
                : (isDark ? Colors.white24 : Colors.black12),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                  width: 2,
                ),
              ),
              child: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny,
                color: isDark ? Colors.amber : Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDark ? 'Modo Escuro' : 'Modo Claro',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDark
                        ? 'Interface escura para conforto visual e menor distração.'
                        : 'Interface clara para uma experiência mais nítida e energizante',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFA9DBF4),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
