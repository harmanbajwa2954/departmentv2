import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';

class LostFoundScreen extends StatelessWidget {
  final String name;

  const LostFoundScreen({super.key, required this.name, required String rollNo});

  Future<void> _reportItem(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Report Lost/Found Item"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Describe the item")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection("lost_found").add({
                    'reportedBy': name,
                    'description': controller.text.trim(),
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
      title: const Text('Lost & Found'),
      actions: [
        IconButton(icon: const Icon(Icons.add_box), onPressed: () => _reportItem(context)),
      ],
    ),
    body: const Center(child: Text("Lost & Found posts will appear here.")),
  );
}
