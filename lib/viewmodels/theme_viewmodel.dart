import 'package:flutter/foundation.dart';

class ThemeViewmodel extends ChangeNotifier {
  bool _isDarkMode;

  ThemeViewmodel({required bool isDarkMode}) : _isDarkMode = isDarkMode;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
