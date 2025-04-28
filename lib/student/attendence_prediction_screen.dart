import 'package:flutter/material.dart';

class AttendancePredictionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Prediction')),
      body: const Center(
        child: Text(
          'AI-based prediction of attendance trends.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
