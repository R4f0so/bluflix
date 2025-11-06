import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

/// Guard para proteger rotas administrativas
class AdminGuard {
  /// Verifica se o usuário atual é admin
  /// Retorna true se for admin, false caso contrário
  static Future<bool> isAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return false;

      final tipoUsuario = userDoc.data()?['tipoUsuario'] ?? '';
      return tipoUsuario == 'admin';
    } catch (e) {
      print('❌ Erro ao verificar admin: $e');
      return false;
    }
  }

  /// Verifica permissão admin e redireciona se não autorizado
  /// Use este método no initState() de telas administrativas
  static Future<void> checkAdminAccess(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (context.mounted) {
        context.go('/login');
      }
      return;
    }

    final isAdminUser = await isAdmin();

    if (!isAdminUser && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Acesso negado! Apenas administradores podem acessar esta área.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      context.go('/catalogo');
    }
  }

  /// Widget wrapper que só renderiza o conteúdo se o usuário for admin
  static Widget protectRoute({required Widget child, Widget? fallback}) {
    return FutureBuilder<bool>(
      future: isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFA9DBF4)),
            ),
          );
        }

        if (snapshot.data == true) {
          return child;
        }

        // Se não for admin, redireciona
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/catalogo');
          }
        });

        return fallback ??
            const Scaffold(body: Center(child: Text('Acesso negado')));
      },
    );
  }
}
