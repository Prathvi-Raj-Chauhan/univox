import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../COMPONENTS/glass_text_field.dart';
import '../SCREENS/main_screen_with_bottom_nav.dart';

final baseUrl = "https://univox-backend-r0u6.onrender.com";

class AccountSetupPage extends StatefulWidget {
  final String? token;
  const AccountSetupPage({super.key, required this.token});

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  File? _imageFile;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
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

    try {
      final uri = Uri.parse("$baseUrl/user/setup");
      final response = http.MultipartRequest("PATCH", uri);
      response.fields['college'] = _college.text.trim();
      response.fields['branch'] = _branch.text.trim();
      response.fields['year'] = _year.text.trim();
      response.fields['username'] = _username.text.trim();
      response.fields['userId'] = userId;

      if (_imageFile != null) {
        final image = await http.MultipartFile.fromPath(
          'profilePicture',
          _imageFile!.path,
        );
        response.files.add(image);
      }

      final responsed = await response.send();
      final resBody = await responsed.stream.bytesToString();

      if (responsed.statusCode == 200 || responsed.statusCode == 201) {
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
        prefs.setString('token', jsonDecode(resBody)['userToken']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                MainScreenWithNavBar(token: jsonDecode(resBody)['userToken']),
          ), // change if needed
          (route) => false,
        );
      } else {
        final errorMsg =
            jsonDecode(resBody)['error'] ?? 'Unknown error occurred';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Setup Failed"),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Network Error"),
          content: Text("Could not connect to server.\n\nDetails: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    // Commented out the cropper due to bug:
    // final cropped = await ImageCropper().cropImage(
    //   sourcePath: picked.path,
    //   aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square
    //   compressFormat: ImageCompressFormat.jpg,
    //   compressQuality: 85,
    //   uiSettings: [
    //     AndroidUiSettings(
    //       toolbarTitle: 'Crop Profile Picture',
    //       toolbarColor: Colors.lightBlueAccent,
    //       toolbarWidgetColor: Colors.white,
    //       initAspectRatio: CropAspectRatioPreset.square,
    //       lockAspectRatio: true,
    //       hideBottomControls: false,
    //       cropFrameStrokeWidth: 2,
    //       cropGridStrokeWidth: 1,
    //       activeControlsWidgetColor: Colors.lightBlueAccent,
    //       statusBarColor: Colors.lightBlueAccent,
    //       backgroundColor: Colors.black,
    //     ),
    //     IOSUiSettings(
    //       title: 'Crop Profile Picture',
    //       aspectRatioLockEnabled: true,
    //     ),
    //   ],
    // );

    // if (cropped != null) {
    //   setState(() {
    //     _imageFile = File(cropped.path);
    //   });
    // }
    // Show image directly after picking
    setState(() {
      _imageFile = File(picked.path);
    });
  }

  @override
  void initState() {
    super.initState();
    initSharedPref(); // <- Initialize prefs here
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
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          /// 🔹 Glass UI Container
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
                        "Setup Account",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: pickImage,
                        child: _imageFile == null
                            ? Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Choose Photo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(55),
                                    child: Image.file(
                                      _imageFile!,
                                      height: 110,
                                      width: 110,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() => _imageFile = null);
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Remove Image",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      glassTextField(
                        controller: _college,
                        obscure: false,
                        hintText: 'College Name',
                      ),
                      const SizedBox(height: 16),

                      glassTextField(
                        controller: _branch,
                        obscure: false,
                        hintText: 'Branch',
                      ),
                      const SizedBox(height: 16),

                      glassTextField(
                        controller: _year,
                        obscure: false,
                        hintText: 'Year',
                      ),
                      const SizedBox(height: 16),

                      glassTextField(
                        controller: _username,
                        hintText: 'Username',
                        obscure: false,
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitDetails,
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.lightBlueAccent.withAlpha(
                            180,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 12,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
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
