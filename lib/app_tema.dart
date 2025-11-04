import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppTema extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  String get backgroundImage => _isDarkMode
      ? 'assets/night_background.png'
      : 'assets/morning_background.png';

  Color get textColor => _isDarkMode ? Colors.white : Colors.black;

  Color get textSecondaryColor => _isDarkMode ? Colors.white70 : Colors.black54;

  Color get backgroundColor => _isDarkMode ? Colors.black : Colors.white;

  // Adicionando a propriedade corSecundaria que estava faltando
  Color get corSecundaria => _isDarkMode
      ? const Color(0xFF1E88E5) // Azul para tema escuro
      : const Color(0xFF1976D2); // Azul mais escuro para tema claro

  // Carregar preferência salva do SharedPreferences
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool('isDarkMode');

      print("════════════════════════════════");
      print("🎨 CARREGANDO TEMA");
      print("   SharedPreferences: $savedTheme");

      if (savedTheme != null) {
        _isDarkMode = savedTheme;
        print(
          "   ✅ Tema carregado do SharedPreferences: ${_isDarkMode ? 'Escuro' : 'Claro'}",
        );
      } else {
        print("   ⚠️ Nenhum tema no SharedPreferences");
      }

      print("════════════════════════════════");

      notifyListeners();
    } catch (e) {
      print("❌ ERRO ao carregar tema: $e");
    }
  }

  // Carregar tema do Firestore (chamado após login)
  Future<void> loadThemeFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print(
          "⚠️ Usuário não autenticado, não é possível carregar tema do Firestore",
        );
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final temaFirestore = userDoc.data()?['temaDark'] as bool?;

        print("════════════════════════════════");
        print("🎨 CARREGANDO TEMA DO FIRESTORE");
        print("   Firestore: $temaFirestore");

        if (temaFirestore != null) {
          _isDarkMode = temaFirestore;

          // Salva no SharedPreferences também para sincronizar
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isDarkMode', _isDarkMode);

          print("   ✅ Tema sincronizado: ${_isDarkMode ? 'Escuro' : 'Claro'}");
          notifyListeners();
        } else {
          print("   ⚠️ Nenhuma preferência de tema no Firestore");
        }

        print("════════════════════════════════");
      } else {
        print("   ⚠️ Documento do usuário não encontrado no Firestore");
      }
    } catch (e) {
      print("❌ ERRO ao carregar tema do Firestore: $e");
    }
  }

  // Alternar e salvar (SharedPreferences + Firestore)
  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;

      print("════════════════════════════════");
      print("🎨 ALTERNANDO TEMA");
      print("   Novo tema: ${_isDarkMode ? 'Escuro' : 'Claro'}");

      // Salva no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final resultLocal = await prefs.setBool('isDarkMode', _isDarkMode);
      print("   ✅ Salvo no SharedPreferences: $resultLocal");

      // Salva no Firestore se estiver logado
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'temaDark': _isDarkMode,
        }, SetOptions(merge: true));
        print("   ✅ Salvo no Firestore");
      } else {
        print("   ⚠️ Usuário não logado, salvou apenas localmente");
      }

      print("════════════════════════════════");

      notifyListeners();
    } catch (e) {
      print("❌ ERRO ao alternar tema: $e");
      // Mesmo com erro, notifica para atualizar a UI
      notifyListeners();
    }
  }

  // Definir e salvar
  Future<void> setDarkMode(bool value) async {
    try {
      _isDarkMode = value;

      print("════════════════════════════════");
      print("🎨 DEFININDO TEMA");
      print("   Valor: ${value ? 'Escuro' : 'Claro'}");

      // Salva no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      print("   ✅ Salvo no SharedPreferences");

      // Salva no Firestore se estiver logado
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'temaDark': _isDarkMode,
        }, SetOptions(merge: true));
        print("   ✅ Salvo no Firestore");
      }

      print("════════════════════════════════");

      notifyListeners();
    } catch (e) {
      print("❌ ERRO ao definir tema: $e");
      notifyListeners();
    }
  }

  // Limpar tema (útil para testes/debug)
  Future<void> clearTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isDarkMode');
      _isDarkMode = false;

      print("🗑️ Tema limpo do SharedPreferences");

      // Remove do Firestore também se estiver logado
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'temaDark': FieldValue.delete()});
        print("🗑️ Tema removido do Firestore");
      }

      notifyListeners();
    } catch (e) {
      print("❌ ERRO ao limpar tema: $e");
    }
  }
}
