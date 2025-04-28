import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:department/widgets/button.dart';
// import 'package:department/widgets/textfield.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  String? selectedCourse;
  String? selectedSemester;

  final List<String> courses = ['Civil Engineering','Computer Science', 'Electronics & Communication', 'Electrical', 'Mechanical Engineering'];
  final List<String> semesters = ['1st Semester', '2nd Semester', '3rd Semester', '4th Semester', '5th Semester', '6th Semester', '7th Semester', '8th Semester'];

  final TextEditingController _subjectController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> addSubject() async {
    if (selectedCourse == null || selectedSemester == null || _subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select course, semester and enter subject name')),
      );
      return;
    }

    try {
      final subjectName = _subjectController.text.trim();

      final subjectRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(selectedCourse)
          .collection('semesters')
          .doc(selectedSemester)
          .collection('subjects')
          .doc(subjectName);

      await subjectRef.set({
        'name': subjectName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _subjectController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subject "$subjectName" added successfully!')),
      );

      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add subject')),
      );
    }
  }

  Stream<QuerySnapshot> getSubjectsStream() {
    if (selectedCourse == null || selectedSemester == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('courses')
        .doc(selectedCourse)
        .collection('semesters')
        .doc(selectedSemester)
        .collection('subjects')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subjects')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Course'),
              value: selectedCourse,
              items: courses.map((course) => DropdownMenuItem(
                value: course,
                child: Text(course),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCourse = value;
                  selectedSemester = null; // Reset semester when course changes
                });
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Semester'),
              value: selectedSemester,
              items: semesters.map((sem) => DropdownMenuItem(
                value: sem,
                child: Text(sem),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSemester = value;
                });
              },
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Enter New Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CustomButton(
                  onPressed: addSubject,
                  label: 'Add',
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Divider(),

            const Text(
              'Existing Subjects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getSubjectsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No subjects found.'));
                  }

                  final subjects = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return ListTile(
                        title: Text(subject['name']),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
