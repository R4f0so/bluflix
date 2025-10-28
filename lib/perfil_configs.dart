import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';

class PerfilConfigsScreen extends StatelessWidget {
  const PerfilConfigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);
    final perfilProvider = Provider.of<PerfilProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

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
                  'Configurações',
                  style: TextStyle(
                    color: appTema.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Lista de configurações
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildConfigCard(
                      context: context,
                      icon: Icons.person_outline,
                      title: 'Perfil',
                      subtitle: user?.email ?? 'Sem e-mail',
                      appTema: appTema,
                      onTap: () {
                        // Apenas perfil pai pode acessar configurações de perfil
                        if (perfilProvider.isPerfilPai) {
                          context.push('/perfilpai-configs');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Apenas o perfil pai pode acessar essas configurações',
                              ),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Mudar Avatar
                    _buildConfigCard(
                      context: context,
                      icon: Icons.face,
                      title: 'Mudar Avatar',
                      subtitle: 'Altere seu avatar de exibição',
                      appTema: appTema,
                      onTap: () {
                        context.push('/mudar-avatar');
                      },
                    ),

                    const SizedBox(height: 16),

                    // Segurança - APENAS para perfil pai
                    if (perfilProvider.isPerfilPai)
                      _buildConfigCard(
                        context: context,
                        icon: Icons.lock_outline,
                        title: 'Segurança',
                        subtitle: 'Configurar PIN de controle parental',
                        appTema: appTema,
                        onTap: () {
                          context.push('/seguranca-config');
                        },
                      ),

                    if (perfilProvider.isPerfilPai) const SizedBox(height: 16),

                    _buildConfigCard(
                      context: context,
                      icon: Icons.palette_outlined,
                      title: 'Tema',
                      subtitle: appTema.isDarkMode
                          ? 'Modo Escuro'
                          : 'Modo Claro',
                      appTema: appTema,
                      onTap: () {
                        context.push('/tema-config');
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildConfigCard(
                      context: context,
                      icon: Icons.notifications_none_outlined,
                      title: 'Notificações',
                      subtitle: 'Gerenciar notificações',
                      appTema: appTema,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Em desenvolvimento...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildConfigCard(
                      context: context,
                      icon: Icons.language_outlined,
                      title: 'Idioma',
                      subtitle: 'Português (Brasil)',
                      appTema: appTema,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Em desenvolvimento...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildConfigCard(
                      context: context,
                      icon: Icons.help_outline,
                      title: 'Ajuda e Suporte',
                      subtitle: 'Central de ajuda',
                      appTema: appTema,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Em desenvolvimento...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildConfigCard(
                      context: context,
                      icon: Icons.info_outline,
                      title: 'Sobre',
                      subtitle: 'Versão 1.0.0',
                      appTema: appTema,
                      onTap: () {
                        _mostrarSobre(context, appTema);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Botão de Logout
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: appTema.isDarkMode
                            ? Colors.blue.withValues(alpha: 0.15)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: appTema.isDarkMode
                              ? Colors.blue.withValues(alpha: 0.4)
                              : Colors.blue.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final router = GoRouter.of(context);

                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) =>
                                  _ConfirmarLogoutDialog(appTema: appTema),
                            );

                            if (confirmar == true) {
                              await FirebaseAuth.instance.signOut();

                              // Usa router salvo antes da operação assíncrona
                              router.go('/options');
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Encerrar Sessão',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appTema.isDarkMode
                                ? Colors.blue[600]
                                : Colors.blue[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required AppTema appTema,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.grey[800]?.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFA9DBF4).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFA9DBF4), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: appTema.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: appTema.textSecondaryColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: appTema.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarSobre(BuildContext context, AppTema appTema) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Sobre o Bluflix',
          style: TextStyle(color: appTema.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width: 100),
            const SizedBox(height: 16),
            Text(
              'Bluflix v1.0.0',
              style: TextStyle(
                color: appTema.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplicativo de streaming desenvolvido com Flutter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: appTema.textSecondaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIÁLOGO: CONFIRMAR LOGOUT
// ═══════════════════════════════════════════════════════════════

class _ConfirmarLogoutDialog extends StatelessWidget {
  final AppTema appTema;

  const _ConfirmarLogoutDialog({required this.appTema});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      title: Row(
        children: [
          Icon(Icons.logout, color: Colors.orange[700], size: 28),
          const SizedBox(width: 12),
          Text(
            'Sair da Conta',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        'Tem certeza que deseja sair da sua conta?',
        style: TextStyle(color: appTema.textSecondaryColor, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: appTema.isDarkMode
                ? Colors.white70
                : Colors.black54,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Sair'),
        ),
      ],
    );
  }
}
