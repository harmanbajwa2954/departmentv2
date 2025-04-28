import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverseeTeachersScreen extends StatelessWidget {
  const OverseeTeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oversee Teacher Activity')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'teacher').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final teachers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return ListTile(
                title: Text(teacher['name']),
                subtitle: Text(teacher['email']),
              );
            },
          );
        },
      ),
    );
  }
}
