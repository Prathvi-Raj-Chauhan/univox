import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../SCREENS/main_screen_with_bottom_nav.dart';

final baseUrl = dotenv.env['BACKEND_URL'];
class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const EditProfilePage({required this.userData, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController collegeController;
  late TextEditingController branchController;
  late TextEditingController yearController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.userData['username']);
    emailController = TextEditingController(text: widget.userData['email']);
    collegeController = TextEditingController(text: widget.userData['college']);
    branchController = TextEditingController(text: widget.userData['branch']);
    yearController = TextEditingController(text: widget.userData['year'].toString());
  }

  Future<void> updateProfile() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('$baseUrl/user/update');
    final body = jsonEncode({
      "userId": widget.userId,
      "username": usernameController.text,
      "email": emailController.text,
      "college": collegeController.text,
      "branch": branchController.text,
      "year": yearController.text,
    });

    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Setup Successful!'),
          content: Text('Redirecting to Account Page...'),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', jsonDecode(response.body)['userToken']);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainScreenWithNavBar(token: jsonDecode(response.body)['userToken']),
        ),
            (route) => false,
      );
    } else {
      final errorMsg = jsonDecode(response.body)['error'] ?? 'Unknown error occurred';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Update Failed"),
          content: Text(errorMsg),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    }
  }

  Widget glassTextField({required String label, required TextEditingController controller, TextInputType type = TextInputType.text}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
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
                        "Edit Profile",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      glassTextField(label: "Username", controller: usernameController),
                      const SizedBox(height: 12),
                      glassTextField(label: "Email", controller: emailController),
                      const SizedBox(height: 12),
                      glassTextField(label: "College", controller: collegeController),
                      const SizedBox(height: 12),
                      glassTextField(label: "Branch", controller: branchController),
                      const SizedBox(height: 12),
                      glassTextField(label: "Year", controller: yearController, type: TextInputType.number),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : updateProfile,
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.deepPurple.withOpacity(0.8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      )
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
