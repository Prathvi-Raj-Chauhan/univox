import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../COMPONENTS/glass_text_field.dart';
import '../SCREENS/main_screen_with_bottom_nav.dart';

final baseUrl = dotenv.env['BACKEND_URL'];

class AccountSetupPage extends StatefulWidget {
  final String? token;
  const AccountSetupPage({super.key, required this.token});

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  late SharedPreferences prefs;
  final TextEditingController _college = TextEditingController();
  final TextEditingController _branch = TextEditingController();
  final TextEditingController _year = TextEditingController();
  final TextEditingController _username = TextEditingController();

  bool _isLoading = false;

  void _submitDetails() async {
    if (_college.text.isEmpty ||
        _branch.text.isEmpty ||
        _year.text.isEmpty ||
        _username.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (widget.token == null || JwtDecoder.isExpired(widget.token!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> decoded = JwtDecoder.decode(widget.token!);
    String userId = decoded['_id'];

    var userBody = {
      "college": _college.text.trim(),
      "branch": _branch.text.trim(),
      "year": _year.text.trim(),
      "username": _username.text.trim(),
      "userId": userId,
    };

    try {
      var response = await http.patch(
        Uri.parse('$baseUrl/user/setup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Setup Successful!'),
            content: Text('Redirecting to home...'),
          ),
        );

        _college.clear();
        _year.clear();
        _branch.clear();
        _username.clear();

        await Future.delayed(const Duration(seconds: 2));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', jsonDecode(response.body)['userToken']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreenWithNavBar(token: jsonDecode(response.body)['userToken'])), // change if needed
              (route) => false,
        );
      } else {
        final errorMsg = jsonDecode(response.body)['error'] ?? 'Unknown error occurred';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Setup Failed"),
            content: Text(errorMsg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Network Error"),
          content: Text("Could not connect to server.\n\nDetails: $e"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    initSharedPref(); // <- Initialize prefs here
  }

  void initSharedPref() async{
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
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Glass UI Container
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 370,
                  height: 600,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Setup Account",
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      glassTextField(
                        controller: _college,
                        hintText: 'College Name',

                      ),
                      const SizedBox(height: 16),

                      glassTextField(
                        controller: _branch,
                        hintText: 'Branch',

                      ),
                      const SizedBox(height: 16),

                      glassTextField(
                        controller: _year,
                        hintText: 'Year',

                      ),
                      const SizedBox(height: 16),

                      glassTextField(
                        controller: _username,
                        hintText: 'Username',
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitDetails,
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.lightBlueAccent.withAlpha(180),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Submit',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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
