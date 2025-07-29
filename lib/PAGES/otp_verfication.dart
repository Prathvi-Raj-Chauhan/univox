import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:univox/COMPONENTS/glass_text_field.dart';
import 'package:univox/PAGES/home_page.dart';
import 'package:univox/PAGES/register.dart';
import 'package:univox/PAGES/setup_account.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:univox/SCREENS/main_screen_with_bottom_nav.dart';
class OtpVerficationPage extends StatefulWidget {
  final String? token;
  final String email;
  const OtpVerficationPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<OtpVerficationPage> createState() => _OtpVerficationPageState();
}

class _OtpVerficationPageState extends State<OtpVerficationPage> {

  final baseUrl = "https://univox-backend-r0u6.onrender.com";
  int count = 0;
  final TextEditingController _otp = new TextEditingController();
  bool _isLoading1 = false;
  bool _isLoading2 = false;



  void VerifyUser() async{
    if (_otp.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the OTP.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading1 = true;
    });
    var verifyOtpbody = {"email": widget.email, "otp" : _otp.text};

    var response = await http.post(
      Uri.parse('${baseUrl}/user/register/verifyotp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(verifyOtpbody),
    );
    var jsonResponse = jsonDecode(response.body);
    final prefs = await SharedPreferences.getInstance();

    if (response.statusCode == 200 || response.statusCode == 201) {
      var userToken = jsonResponse['token'];
        prefs.setString('token', userToken);
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(title: Text('Successfully Verified')),
        );

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
        Navigator.of(context).pushAndRemoveUntil(
          /// if we use pushReplacement user wont be able to get back to this page
          MaterialPageRoute(
            builder: (context) => MainScreenWithNavBar(token: userToken),
          ),
          (route) => false,
        );
      }
        
        
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    else if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect OTP.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP expired. Please request a new one.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed. Try again later.'),
          backgroundColor: Colors.grey,
        ),
      );
    }
    setState(() {
      _isLoading1 = false;
    });
  }

  void SendOtp() async {
    setState(() {
      _isLoading2 = true;
      count++;
    });
    var sendOtpbody = {"email": widget.email};

    var response = await http.post(
      Uri.parse('${baseUrl}/user/register/sendotp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(sendOtpbody),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP Sent successfully! Check your mail'),
        ),
      );
    }
    else{
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed To send Otp, Try Again later!'),
        ),
      );
    }
    setState(() {
      _isLoading2 = false;
    });
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
                          "Verify Your Email",
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.email,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 5),
                        SizedBox(height: 16),

                        glassTextField(controller: _otp, hintText: 'Enter OTP', obscure: true,),

                        SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _isLoading1 ? null : () => VerifyUser(),
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
                          child: _isLoading1
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
                                      'Verify',
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
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isLoading2 ? null : () => SendOtp(),
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
                          child: _isLoading2
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
                                      count == 0 ? 'Send Otp' : 'Re-Send Otp',
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
                            Text('Wrong Email Entered ?'),
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
                                'Correct Now!',
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
