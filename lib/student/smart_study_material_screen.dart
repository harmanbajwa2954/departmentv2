import 'package:flutter/material.dart';

class SmartStudyMaterialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Study Material')),
      body: const Center(
        child: Text(
          'AI-powered study material suggestions will appear here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
