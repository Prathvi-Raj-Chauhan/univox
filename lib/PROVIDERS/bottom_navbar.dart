import 'package:flutter/material.dart';

class BottomNavProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex; //✅ A getter that allows external widgets to read the value of _selectedIndex, but not modify it directly.

  void changeIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); //Calls notifyListeners() — which notifies all widgets that are listening to this provider, so they rebuild accordingly.
  }
}