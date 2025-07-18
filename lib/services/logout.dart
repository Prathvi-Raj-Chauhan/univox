import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../PAGES/login_page.dart';


Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // clear the token

  // Navigate to login page and clear the navigation stack
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => loginPage()),
        (route) => false,
  );
}