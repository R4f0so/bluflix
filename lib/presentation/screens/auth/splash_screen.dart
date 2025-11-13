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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarAutenticacao();
  }

  Future<void> _verificarAutenticacao() async {
    try {
      print('🔍 Verificando autenticação...');

      // ✅ CRÍTICO: Obter provider ANTES de qualquer await
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );

      // Aguardar um pouco para exibir splash
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // ✅ Verificar se o usuário já está logado
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        print('✅ Usuário já autenticado: ${user.email}');
        print('   UID: ${user.uid}');

        // Buscar dados do usuário no Firestore
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
          await perfilProvider.setPerfilAtivo(
            apelido: apelido,
            avatar: avatar,
            isPai: true,
          );

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
          print('❌ Documento do usuário não encontrado');
          if (!mounted) return;
          context.go('/options');
        }
      } else {
        // Usuário não está logado
        print('❌ Nenhum usuário autenticado - indo para /options');
        if (!mounted) return;
        context.go('/options');
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
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do app
            Icon(Icons.play_circle_filled, size: 100, color: Color(0xFFA9DBF4)),
            SizedBox(height: 20),
            Text(
              'BluFlix',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Color(0xFFA9DBF4)),
          ],
        ),
      ),
    );
  }
}
