import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentInsightsScreen extends StatelessWidget {
  const DepartmentInsightsScreen({super.key});

  Future<Map<String, int>> _fetchCounts() async {
    final students = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').get();
    final teachers = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'teacher').get();
    final complaints = await FirebaseFirestore.instance.collection('complaints').get();
    return {
      'Students': students.docs.length,
      'Teachers': teachers.docs.length,
      'Complaints': complaints.docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Department Insights')),
      body: FutureBuilder<Map<String, int>>(
        future: _fetchCounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final counts = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: counts.entries.map((entry) {
              return Card(
                child: ListTile(
                  title: Text(entry.key),
                  trailing: Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
