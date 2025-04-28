import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveMaterialsScreen extends StatelessWidget {
  const ApproveMaterialsScreen({super.key});

  void _updateMaterialStatus(String id, String status) {
    FirebaseFirestore.instance.collection('study_materials').doc(id).update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Study Materials')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('study_materials').where('status', isEqualTo: 'Pending').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final materials = snapshot.data!.docs;
          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              return Card(
                child: ListTile(
                  title: Text(material['title']),
                  subtitle: Text('Uploaded by: ${material['uploadedBy']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _updateMaterialStatus(material.id, 'Approved')),
                      IconButton(icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _updateMaterialStatus(material.id, 'Rejected')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
