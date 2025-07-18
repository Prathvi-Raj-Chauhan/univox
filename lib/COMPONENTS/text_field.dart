import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final int maxlines;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.icon,
    required this.maxlines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Top align icon
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Icon(icon, size: 28), // Fixed at top
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(

              controller: controller,
              maxLines: maxlines != 0 ? maxlines : null,
              keyboardType: maxlines > 1 ? TextInputType.multiline : TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.8),
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 18, color: Colors.black54),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white, width: 5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white, width: 8),
                ),
              ),
              cursorColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
