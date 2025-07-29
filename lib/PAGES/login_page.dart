import 'dart:convert';
import 'dart:ui'; // for ImageFilter

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:univox/PAGES/register.dart';

import '../COMPONENTS/glass_text_field.dart';
import '../services/loginUser.dart';

class loginPage extends StatefulWidget {
  final String? token;
  const loginPage({super.key, this.token});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _pass = TextEditingController();

  late SharedPreferences prefs;
  bool _isLoading = false; 

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
                    color: Colors.white.withAlpha(102), // 0.4 * 255 = 102
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Login",
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

                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await loginUser(
                                    context,
                                    _email,
                                    _pass,
                                    prefs,
                                    widget.token,
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.lightBlueAccent.withAlpha(
                              179,
                            ), // 0.7 * 255 = 179
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 90,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('New User? '),
                            GestureDetector(
                              onTap: () => {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        registerPage(token: widget.token),
                                  ),
                                ),
                              },
                              child: Text(
                                'Register Now!',
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
