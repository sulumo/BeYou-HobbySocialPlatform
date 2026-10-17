import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void updateIndex(int newIndex) {
    if (newIndex != _selectedIndex) {
      _selectedIndex = newIndex;
      notifyListeners();
    }
  }
}
