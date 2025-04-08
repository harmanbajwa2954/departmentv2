import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class StudyMaterialsScreen extends StatelessWidget {
  final String name;

  const StudyMaterialsScreen({super.key, required this.name});

  Future<void> _uploadMaterial(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        // Upload file to Firebase Storage
        final ref = FirebaseStorage.instance.ref('study_materials/$fileName');
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Save file metadata to Firestore
        await FirebaseFirestore.instance.collection('study_materials').add({
          'uploadedBy': name,
          'fileName': fileName,
          'url': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _uploadMaterial(context),
          ),
        ],
      ),
      body: const Center(
        child: Text("Study materials will be shown here."),
      ),
    );
  }
}
