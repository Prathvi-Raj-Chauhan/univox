import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../PAGES/login_page.dart';
import 'main_screen_with_bottom_nav.dart';


class Authgate extends StatefulWidget {
  final String? token;
  Authgate({super.key, required this.token});

  @override
  State<Authgate> createState() => _AuthgateState();
}

class _AuthgateState extends State<Authgate> {
  @override
  Widget build(BuildContext context) {
    final token = widget.token ?? '';

    // 1. No token or empty
    if (token.trim().isEmpty) {
      return loginPage(token: widget.token);
    }

    // 2. Decode once
    Map<String, dynamic> payload;
    try {
      payload = JwtDecoder.decode(token);
    } catch (_) {
      // not a parseable JWT
      return loginPage(token: widget.token,);
    }

    // 3. Check `exp`
    final expClaim = payload['exp'];
    if (expClaim == null || JwtDecoder.isExpired(token)) {
      return loginPage(token: widget.token,);
    }

    // 4. All good

    return MainScreenWithNavBar(token: widget.token);
  }
}
