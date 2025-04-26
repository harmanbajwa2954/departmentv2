import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:department/widgets/button.dart';
// import 'package:department/widgets/textfield.dart';

class TeacherMarkAttendanceScreen extends StatefulWidget {
  const TeacherMarkAttendanceScreen({super.key});

  @override
  State<TeacherMarkAttendanceScreen> createState() => _TeacherMarkAttendanceScreenState();
}

class _TeacherMarkAttendanceScreenState extends State<TeacherMarkAttendanceScreen> {
  String? selectedCourse;
  String? selectedSem;
  String? selectedSection;
  final List<String> subjects = ['Computer Networks', 'Data Structures', 'Operating Systems'];
  String? selectedSubject;


  final List<String> courses = ['Civil Engineering','Computer Science', 'Electronics & Communication', 'Electrical', 'Mechanical Engineering'];
  final List<String> semesters = ['1st Semester', '2nd Semester', '3rd Semester', '4th Semester', '5th Semester', '6th Semester', '7th Semester', '8th Semester'];
  final List<String> sections = ['12', '34', '56','78'];

  List<Map<String, dynamic>> students = [];
  Map<String, bool> attendanceMap = {};

  void loadStudentsFromFirestore() async {
    if (selectedCourse == null || selectedSem == null || selectedSection == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('course', isEqualTo: selectedCourse)
          .where('year', isEqualTo: selectedSem)
          .where('section', isEqualTo: selectedSection)
          .get();

      students = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['name'],
      }).toList();

      attendanceMap = {
        for (var student in students) student['id']: false,
      };

      setState(() {});
    } catch (e) {
      print("Error loading students: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load students')),
      );
    }
  }


  void submitAttendance() async {
    if (selectedCourse == null || selectedSem == null || selectedSection == null || selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select course, year, section and subject')),
      );
      return;
    }

    final date = DateTime.now();
    final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      for (var entry in attendanceMap.entries) {
        final studentId = entry.key;
        final isPresent = entry.value;

        final attendanceRef = FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .collection('attendance')
            .doc(selectedSubject!)  // ✅ Now grouped under subject
            .collection('records')
            .doc(dateString);

        await attendanceRef.set({
          'status': isPresent ? 'Present' : 'Absent',
          'timestamp': FieldValue.serverTimestamp(),
          'course': selectedCourse,
          'year': selectedSem,
          'section': selectedSection,
          'subject': selectedSubject,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance submitted successfully!')),
      );

      setState(() {
        students.clear();
        attendanceMap.clear();
        selectedSubject = null;
      });
    } catch (e) {
      print('Error submitting attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit attendance')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdowns
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Course'),
              value: selectedCourse,
              items: courses.map((course) => DropdownMenuItem(
                value: course,
                child: Text(course),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCourse = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Semester'),
              value: selectedSem,
              items: semesters.map((semester) => DropdownMenuItem(
                value: semester,
                child: Text(semester),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSem = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Section'),
              value: selectedSection,
              items: sections.map((section) => DropdownMenuItem(
                value: section,
                child: Text(section),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSection = value!;
                  loadStudentsFromFirestore();
                });
              },
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Subject'),
              value: selectedSubject,
              items: subjects.map((subject) => DropdownMenuItem(
                value: subject,
                child: Text(subject),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value!;
                  loadStudentsFromFirestore(); // ⚡ Only load students once everything is selected
                });
              },
            ),

            // Students List
            if (students.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isPresent = attendanceMap[student['id']] ?? false;

                    return ListTile(
                      title: Text(student['name']),
                      trailing: Switch(
                        value: isPresent,
                        onChanged: (val) {
                          setState(() {
                            attendanceMap[student['id']] = val;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

            if (students.isNotEmpty)
              CustomButton(
                onPressed: submitAttendance,
                label: 'Submit Attendance',
              ),
          ],
        ),
      ),
    );
  }
}
