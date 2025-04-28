import 'package:flutter/material.dart';

class ReviewSubmissionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Student Submissions')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(
            title: Text('John Doe - Assignment 1'),
            subtitle: Text('Submitted on: 2025-04-22'),
            trailing: Icon(Icons.arrow_forward),
          ),
          ListTile(
            title: Text('Jane Smith - Assignment 2'),
            subtitle: Text('Submitted on: 2025-04-20'),
            trailing: Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
