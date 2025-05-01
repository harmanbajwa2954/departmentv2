import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewComplaintsScreen extends StatelessWidget {
  const ViewComplaintsScreen({super.key});

  Stream<QuerySnapshot> getComplaintsStream() {
    return FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Complaints')),
      body: StreamBuilder<QuerySnapshot>(
        stream: getComplaintsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }

          final complaints = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final data = complaint.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Title';
              final description = data['description'] ?? 'No Description';


              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.report_problem, color: Colors.redAccent),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(description),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
