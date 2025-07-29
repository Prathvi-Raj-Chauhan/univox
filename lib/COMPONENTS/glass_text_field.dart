import 'package:flutter/material.dart';

class glassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  const glassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.8)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 1),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white, // white border
            width: 1.5,
          ),
        ),

        // White border when focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white, // white border
            width: 2,
          ),
        ),
      ),
    );
  }
}
