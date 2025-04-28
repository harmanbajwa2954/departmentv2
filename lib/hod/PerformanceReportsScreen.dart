import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PerformanceReportsScreen extends StatelessWidget {
  const PerformanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Reports & Analytics')),
      body: Center(
        child: Text('This section will show department performance reports and graphs.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
