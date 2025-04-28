import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EscalatedComplaintsScreen extends StatelessWidget {
  const EscalatedComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Handle Escalated Complaints')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('complaints').where('status', isEqualTo: 'Escalated').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final complaints = snapshot.data!.docs;
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return ListTile(
                title: Text(complaint['title']),
                subtitle: Text(complaint['description']),
              );
            },
          );
        },
      ),
    );
  }
}
