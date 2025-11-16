import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
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
  
  bool _isLoadingTheme = true; // ✅ NOVO: Controla carregamento do tema
  String _backgroundImage = 'assets/morning_background.png'; // ✅ NOVO: Background padrão

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
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // ✅ NOVO: Carregar tema PRIMEIRO
    _carregarTemaENavegar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ NOVO: Carregar tema antes de navegar
  // ═══════════════════════════════════════════════════════════════
  Future<void> _carregarTemaENavegar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // ✅ Usuário logado: Carregar tema do Firestore
        final appTema = Provider.of<AppTema>(context, listen: false);
        await appTema.loadThemeFromFirestore();

        if (!mounted) return;

        // ✅ Atualizar background baseado no tema
        setState(() {
          _backgroundImage = appTema.backgroundImage;
          _isLoadingTheme = false;
        });

        print('🎨 Tema carregado: ${appTema.isDarkMode ? "Escuro" : "Claro"}');
        print('   Background: $_backgroundImage');
      } else {
        // ✅ Não logado: Usar tema padrão (claro)
        if (!mounted) return;
        setState(() {
          _isLoadingTheme = false;
        });
        print('🎨 Tema padrão (usuário não logado)');
      }

      // ✅ Aguardar 3 segundos E tema carregado
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted) return;
      _verificarAutenticacao();
    } catch (e) {
      print('❌ Erro ao carregar tema: $e');
      
      // Em caso de erro, usar tema padrão e continuar
      if (!mounted) return;
      setState(() {
        _isLoadingTheme = false;
      });

      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _verificarAutenticacao();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // VERIFICAR AUTENTICAÇÃO E REDIRECIONAR
  // ═══════════════════════════════════════════════════════════════
  Future<void> _verificarAutenticacao() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('🔓 Usuário NÃO logado - redirecionando para /options');
        if (!mounted) return;
        context.go('/options');
        return;
      }

      print('🔐 Usuário logado detectado: ${user.email}');
      print('   UID: ${user.uid}');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (!userDoc.exists) {
        print('⚠️ Documento do usuário não existe - criando...');
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'apelido': null,
          'avatar': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        context.go('/avatar');
        return;
      }

      final userData = userDoc.data();

      if (userData?['apelido'] == null || userData?['avatar'] == null) {
        print('⚠️ Onboarding incompleto - redirecionando para /avatar');
        if (!mounted) return;
        context.go('/avatar');
        return;
      }

      // ✅ Tema já foi carregado em _carregarTemaENavegar()

      if (!mounted) return;
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );

      await perfilProvider.setPerfilAtivo(
        apelido: userData?['apelido'] ?? 'Usuário',
        avatar: userData?['avatar'] ?? 'assets/avatar1.png',
        isPai: true,
      );

      final tipoUsuario = userData?['tipoUsuario'] ?? '';
      final isAdmin = tipoUsuario == 'admin';

      print('🎬 Redirecionamento:');
      print('   Apelido: ${userData?['apelido']}');
      print('   Tipo: $tipoUsuario');
      print('   É admin? $isAdmin');

      if (!mounted) return;

      if (isAdmin) {
        print('   → Redirecionando para /gerenciamento-admin');
        context.go('/gerenciamento-admin');
      } else {
        print('   → Redirecionando para /gerenciamento-pais');
        context.go('/gerenciamento-pais');
      }
    } catch (e) {
      print('❌ Erro ao verificar autenticação: $e');
      if (!mounted) return;
      context.go('/options');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_backgroundImage), // ✅ DINÂMICO
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoadingTheme
            ? const SizedBox.shrink() // ✅ Esconde logo enquanto carrega tema
            : Center(
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