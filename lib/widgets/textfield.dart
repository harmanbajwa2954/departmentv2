import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({super.key, 
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2)
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue,width: 2)
        ),
        prefixIcon: isPassword ? Icon(Icons.lock) : null,
      ),
    );
  }
}
