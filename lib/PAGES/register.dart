import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:univox/PAGES/otp_verfication.dart';
import 'package:univox/PAGES/setup_account.dart';

import 'package:http/http.dart' as http;

import '../COMPONENTS/glass_text_field.dart';
import 'login_page.dart';

final baseUrl = "https://univox-backend-r0u6.onrender.com";

class registerPage extends StatefulWidget {
  final String? token;

  const registerPage({super.key, required this.token});

  @override
  State<registerPage> createState() => _registerPageState();
}

class _registerPageState extends State<registerPage> {
  late SharedPreferences prefs;

  final TextEditingController _email = TextEditingController();

  final TextEditingController _pass = TextEditingController();

  final TextEditingController _cnfpass = TextEditingController();

  bool _isLoading = false;

  void RegisterUser() async {
    
  final isValidEmail = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
      .hasMatch(_email.text.trim());

  if (!isValidEmail) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Invalid Email Address'),
        content: Text('Please enter a valid email.'),
      ),
    );
    return;
  }

  if (_pass.text != _cnfpass.text) {
    showDialog(
      context: context,
      builder: (context) =>
          const AlertDialog(title: Text('Passwords Didn\'t match')),
    );
  } else {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      var regBody = {"email": _email.text.trim(), "password": _pass.text};
      var response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var userToken = jsonResponse['userToken'];
        prefs.setString('token', userToken);

        showDialog(
          context: context,
          builder: (context) =>
              const AlertDialog(title: Text('Successfully Registered')),
        );

        String email = _email.text.trim();
        setState(() {
          _email.clear();
          _pass.clear();
          _cnfpass.clear();
        });

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                OtpVerficationPage(token: userToken, email: email),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Registration Failed'),
          content: Text('Email already exists or some error occurred.'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // use your image path
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Foreground content with glass effect
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 370,
                  height: 550,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 16),

                        glassTextField(
                          controller: _email,
                          obscure: false,
                          hintText: 'Enter Email',
                        ),

                        SizedBox(height: 16),

                        glassTextField(
                          controller: _pass,
                          obscure: true,
                          hintText: 'Enter Password',
                        ),

                        SizedBox(height: 20),

                        glassTextField(
                          controller: _cnfpass,
                          obscure: true,
                          hintText: 'Re-Enter Password',
                        ),

                        SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _isLoading ? null : () => RegisterUser(),
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.lightBlueAccent.withValues(
                              alpha: 0.7,
                            ),
                            shadowColor: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 3,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Submit and Verify Email',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an Account ? '),
                            GestureDetector(
                              onTap: () => {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        loginPage(token: widget.token),
                                  ),
                                ),
                              },
                              child: Text(
                                'Login Now!',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
