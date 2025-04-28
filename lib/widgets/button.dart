import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width *0.05),
      padding: EdgeInsets.symmetric(horizontal: width *0.05,vertical: height*0.05),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white, // ✅ ensures white text
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white, // ✅ Just in case foregroundColor gets overridden
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
