import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilProvider extends ChangeNotifier {
  String? _perfilAtivoApelido;
  String? _perfilAtivoAvatar;
  bool _isPerfilPai = true;

  String? get perfilAtivoApelido => _perfilAtivoApelido;
  String? get perfilAtivoAvatar => _perfilAtivoAvatar;
  bool get isPerfilPai => _isPerfilPai;

  // Carregar perfil ativo salvo
  Future<void> loadPerfilAtivo() async {
    final prefs = await SharedPreferences.getInstance();
    _perfilAtivoApelido = prefs.getString('perfilAtivoApelido');
    _perfilAtivoAvatar = prefs.getString('perfilAtivoAvatar');
    _isPerfilPai = prefs.getBool('isPerfilPai') ?? true;
    notifyListeners();
  }

  // Definir perfil ativo
  Future<void> setPerfilAtivo({
    required String apelido,
    required String avatar,
    required bool isPai,
  }) async {
    _perfilAtivoApelido = apelido;
    _perfilAtivoAvatar = avatar;
    _isPerfilPai = isPai;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfilAtivoApelido', apelido);
    await prefs.setString('perfilAtivoAvatar', avatar);
    await prefs.setBool('isPerfilPai', isPai);

    notifyListeners();
  }

  // Limpar perfil ativo (usado no logout)
  Future<void> clearPerfilAtivo() async {
    _perfilAtivoApelido = null;
    _perfilAtivoAvatar = null;
    _isPerfilPai = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('perfilAtivoApelido');
    await prefs.remove('perfilAtivoAvatar');
    await prefs.remove('isPerfilPai');

    notifyListeners();
  }
}
