import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../SCREENS/main_screen_with_bottom_nav.dart';

final baseUrl = "https://univox-backend-r0u6.onrender.com";

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const EditProfilePage({required this.userData, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? newProfilePicFile; // for the newly picked image

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController collegeController;
  late TextEditingController branchController;
  late TextEditingController yearController;
  late String profilePictureURL;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(
      text: widget.userData['username'],
    );
    emailController = TextEditingController(text: widget.userData['email']);
    collegeController = TextEditingController(text: widget.userData['college']);
    branchController = TextEditingController(text: widget.userData['branch']);
    yearController = TextEditingController(
      text: widget.userData['year'].toString(),
    );
    profilePictureURL = widget.userData['profilePictureURL'] ?? "";
  }

  Future<void> pickNewProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        newProfilePicFile = File(picked.path);
      });
      // Optionally: upload the new image to your backend here
    }
  }

  Future<void> updateProfile() async {
    setState(() => _isLoading = true);

    final uri = Uri.parse('$baseUrl/user/update');
    final request = http.MultipartRequest('PATCH', uri);

    request.fields['userId'] = widget.userId;
    request.fields['username'] = usernameController.text;
    request.fields['email'] = emailController.text;
    request.fields['college'] = collegeController.text;
    request.fields['branch'] = branchController.text;
    request.fields['year'] = yearController.text;

    // Adding image file if picked
    if (newProfilePicFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePicture', //
          newProfilePicFile!.path,
        ),
      );
    }

    // Sending the request
    final streamedResponse = await request.send();
    final response = await streamedResponse.stream.bytesToString();

    setState(() => _isLoading = false);

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Setup Successful!'),
          content: Text('Redirecting to Account Page...'),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', jsonDecode(response)['userToken']);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              MainScreenWithNavBar(token: jsonDecode(response)['userToken']),
        ),
        (route) => false,
      );
    } else {
      final errorMsg =
          jsonDecode(response)['error'] ?? 'Unknown error occurred';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Update Failed"),
          content: Text(errorMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Widget glassTextField({
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
  }) {
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
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 370,
                  height: 650,
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
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: newProfilePicFile != null
                                ? FileImage(newProfilePicFile!)
                                : (profilePictureURL.isNotEmpty
                                      ? NetworkImage(profilePictureURL)
                                      : AssetImage('assets/default.png')
                                            as ImageProvider),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: InkWell(
                              onTap: pickNewProfileImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.deepPurple,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      glassTextField(
                        label: "Username",
                        controller: usernameController,
                      ),
                      const SizedBox(height: 12),
                      glassTextField(
                        label: "Email",
                        controller: emailController,
                      ),
                      const SizedBox(height: 12),
                      glassTextField(
                        label: "College",
                        controller: collegeController,
                      ),
                      const SizedBox(height: 12),
                      glassTextField(
                        label: "Branch",
                        controller: branchController,
                      ),
                      const SizedBox(height: 12),
                      glassTextField(
                        label: "Year",
                        controller: yearController,
                        type: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : updateProfile,
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.deepPurple.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 12,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
