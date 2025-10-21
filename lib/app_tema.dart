import 'package:flutter/material.dart';

class AppTema extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  String get backgroundImage => _isDarkMode
      ? 'assets/night_background.png'
      : 'assets/morning_background.png';

  Color get textColor => _isDarkMode ? Colors.white : Colors.black;

  Color get textSecondaryColor => _isDarkMode ? Colors.white70 : Colors.black54;

  Color get backgroundColor => _isDarkMode ? Colors.black : Colors.white;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}
