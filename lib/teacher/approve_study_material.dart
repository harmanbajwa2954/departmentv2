import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:department/auth/auth_service.dart';
import 'package:department/widgets/button.dart';
import 'dart:io';

class UploadStudyMaterialScreen extends StatefulWidget {
  @override
  _UploadStudyMaterialScreenState createState() => _UploadStudyMaterialScreenState();
}

class _UploadStudyMaterialScreenState extends State<UploadStudyMaterialScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Study Material")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Subject"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _semesterController,
              decoration: const InputDecoration(labelText: "Semester"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Material Title"),
            ),
            const SizedBox(height: 12),
            TextButton.icon(onPressed: _pickFile, label: const Text("Select File"), icon: const Icon(Icons.attach_file)),
            // File Picker Section
            CustomButton(
              label:  "Choose PDF/Image",
              onPressed: _pickFile,
            ),

            const SizedBox(height: 24),
            _isUploading
                ? CircularProgressIndicator()
                : CustomButton(
              onPressed: _uploadMaterial,
              label: "Upload",
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadMaterial() async {
    final subject = _subjectController.text.trim();
    final semester = _semesterController.text.trim();
    final title = _titleController.text.trim();

    if (subject.isEmpty || semester.isEmpty || title.isEmpty || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields and select a file")),
      );
      return;
    }

    try {
      setState(() => _isUploading = true);

      final fileRef = FirebaseStorage.instance
          .ref()
          .child('study_materials')
          .child(subject)
          .child(semester)
          .child(DateTime.now().millisecondsSinceEpoch.toString() + '_' + _fileName!);

      await fileRef.putFile(_selectedFile!);
      final downloadUrl = await fileRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('study_materials')
          .doc(subject)
          .collection(semester)
          .add({
        'title': title,
        'fileUrl': downloadUrl,
        'fileName': _fileName,
        'uploadedBy': AuthService().getCurrentUser()?.uid ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Study material uploaded successfully")),
      );

      _subjectController.clear();
      _semesterController.clear();
      _titleController.clear();
      setState(() {
        _fileName = null;
        _selectedFile = null;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading material: $e")),
      );
    }
  }
}
