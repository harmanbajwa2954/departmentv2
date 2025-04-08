import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';

class ComplaintScreen extends StatelessWidget {
  final String name;

  const ComplaintScreen({super.key, required this.name, required String rollNo});

  Future<void> _submitComplaint(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Submit Complaint"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Type your complaint")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection("complaints").add({
                    'submittedBy': name,
                    'complaint': controller.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text("Submit")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Complaint Registration'),
      actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () => _submitComplaint(context)),
      ],
    ),
    body: const Center(child: Text("Complaints will be listed here.")),
  );
}
