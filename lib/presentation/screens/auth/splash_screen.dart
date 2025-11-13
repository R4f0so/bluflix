import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // ✅ MODIFICADO: Verificar autenticação antes de navegar
    _verificarAutenticacao();
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ NOVO: Verificar se o usuário já está logado
  // ═══════════════════════════════════════════════════════════════
  Future<void> _verificarAutenticacao() async {
    // Aguardar animação do splash (3 segundos)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      print('🔍 Verificando autenticação...');

      // Verificar se existe um usuário autenticado
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // ✅ Usuário está logado
        print('✅ Usuário já autenticado: ${user.email}');
        print('   UID: ${user.uid}');

        // Carregar dados do usuário do Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (userDoc.exists) {
          final data = userDoc.data();
          final tipoUsuario = data?['tipoUsuario'] ?? '';
          final isAdmin = tipoUsuario == 'admin';
          
          final apelido = data?['apelido'] ?? 'Usuário';
          final avatar = data?['avatar'] ?? 'assets/avatar1.png';

          // Configurar perfil ativo
          final perfilProvider = Provider.of<PerfilProvider>(
            context,
            listen: false,
          );
          
          // Carregar perfil salvo do SharedPreferences (se houver)
          await perfilProvider.loadPerfilAtivo();
          
          // Se não houver perfil salvo, definir como perfil pai (usuário principal)
          if (perfilProvider.perfilAtivoApelido == null) {
            await perfilProvider.setPerfilAtivo(
              apelido: apelido,
              avatar: avatar,
              isPai: true,
            );
          }

          if (!mounted) return;

          // Redirecionar para tela apropriada
          if (isAdmin) {
            print('🎬 ADMIN - Redirecionando para /gerenciamento-admin');
            context.go('/gerenciamento-admin');
          } else {
            print('👤 USUÁRIO COMUM - Redirecionando para /gerenciamento-pais');
            context.go('/gerenciamento-pais');
          }
        } else {
          // Documento não existe, fazer logout e ir para options
          print('❌ Documento do usuário não encontrado');
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          context.go('/options');
        }
      } else {
        // ❌ Usuário não está logado
        print('❌ Nenhum usuário autenticado - indo para /options');
        if (!mounted) return;
        context.go('/options');
      }
    } catch (e) {
      print('❌ Erro ao verificar autenticação: $e');
      if (!mounted) return;
      // Em caso de erro, ir para tela de options
      context.go('/options');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Image.asset("assets/logo.png", width: 250),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}