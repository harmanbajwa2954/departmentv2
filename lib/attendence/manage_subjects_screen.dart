import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:department/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> addSubject({
    required String subjectName,
    required String course,
    required String year,
    required String section,
  }) async {
    final teacherUid = FirebaseAuth.instance.currentUser?.uid;

    if (teacherUid == null) throw 'Not logged in as teacher';

    final subjectId = '$subjectName - ${course}_$year\_$section';

    await FirebaseFirestore.instance
        .collection('teachers')
        .doc(teacherUid)
        .collection('attendance')
        .doc(subjectId)
        .set({
      'subject': subjectName,
      'course': course,
      'year': year,
      'section': section,
      'teacherId': teacherUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  Stream<QuerySnapshot> getSubjectsStream() {
    final teacherUid = FirebaseAuth.instance.currentUser?.uid;
    if (teacherUid == null || selectedCourse == null || selectedSemester == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('teachers')
        .doc(teacherUid)
        .collection('attendance')
        .where('course', isEqualTo: selectedCourse)
        .where('year', isEqualTo: selectedSemester)
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
                  label: 'Add',
                  onPressed: () async {
                    if (_subjectController.text.trim().isEmpty ||
                        selectedCourse == null ||
                        selectedSemester == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    try {
                      await addSubject(
                        subjectName: _subjectController.text.trim(),
                        course: selectedCourse!,
                        year: selectedSemester!,
                        section: '12',
                        // 🔁 Replace with actual selected section if applicable
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subject added successfully')),
                      );

                      _subjectController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add subject: $e')),
                      );
                    }
                  },

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
                      final data = subject.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['subject'] ?? 'Unnamed Subject'),
                        subtitle: Text('${data['course']} | ${data['semester']} | Section ${data['section']}'),
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
