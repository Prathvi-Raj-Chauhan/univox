import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../PAGES/setup_account.dart';
import '../SCREENS/main_screen_with_bottom_nav.dart';

final baseUrl = dotenv.env['BACKEND_URL'];

Future<void> loginUser(BuildContext context, TextEditingController _email, TextEditingController _pass, SharedPreferences prefs, String? token) async{
  var loginBody = {
    "email":_email.text,
    "password":_pass.text
  };
  try{
    var response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(loginBody),
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      var userToken = jsonResponse['userToken'];
      prefs.setString('token', userToken);
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Login Success'),
            ),
      );

      _email.clear();
      _pass.clear();
      Map<String, dynamic> map = JwtDecoder.decode(userToken);
      if((map['college'] ?? '') == '' ||
          (map['branch'] ?? '') == '' ||
          (map['year'] ?? '') == '' ||
          (map['username'] ?? '') == ''){
        Navigator.of(context).pushAndRemoveUntil(/// if we use pushAndRemoveUntil user wont be able to get back to this page
          MaterialPageRoute(builder: (context) => AccountSetupPage(token: userToken)),
              (route) => false,
        );
        return;
      }
      else{
        Navigator.of(context).pushAndRemoveUntil(/// if we use pushAndRemoveUntil user wont be able to get back to this page
          MaterialPageRoute(builder: (context) => MainScreenWithNavBar(token: userToken)),
              (route) => false,
        );
      }

      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => mainScreeWithNavBar()),
      // );
    }
    else if(response.statusCode == 400 || response.statusCode == 404){
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Login Failed"),
          content: Text("No Account exists with given email. Create new account"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
          ],
        ),
      );
    }
    else{
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Login Failed"),
          content: Text("Invalid credentials or server error."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
          ],
        ),
      );
    }


  }catch(_){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Network Error"),
        content: Text("Could not connect to server"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }
}