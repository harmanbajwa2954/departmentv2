import 'package:flutter/material.dart';
import 'package:department/widgets/button.dart';


class TeacherAttendanceUI extends StatefulWidget {
  const TeacherAttendanceUI({super.key});

  @override
  State<TeacherAttendanceUI> createState() => _TeacherAttendanceUIState();
}

class _TeacherAttendanceUIState extends State<TeacherAttendanceUI> {
  String? selectedCourse;
  String? selectedYear;
  String? selectedSection;

  final List<String> courses = ['ComputerScience', 'Mechanical', 'ECE' ,'Civil' , 'ECM'];
  final List<String> years = ['1st Year', '2nd Year', '3rd Year' , '4th Year'];
  final List<String> sections = ['12', '34', '56','78'];

  // Mock student data for demo
  List<Map<String, dynamic>> students = [];

  Map<String, bool> attendanceMap = {};

  void loadStudents() {
    // This would be replaced with a Firestore call later
    students = List.generate(10, (index) => {
      'id': 'stu_$index',
      'name': 'Student ${index + 1}',
    });

    attendanceMap = {
      for (var student in students) student['id']: false,
    };

    setState(() {});
  }

  void submitAttendance() {
    print('Attendance Submitted:');
    attendanceMap.forEach((id, present) {
      final student = students.firstWhere((s) => s['id'] == id);
      print('${student['name']} - ${present ? "Present" : "Absent"}');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance submitted (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Course Dropdown
            DropdownButtonFormField<String>(
              value: selectedCourse,
              decoration: InputDecoration(labelText: 'Select Course'),
              items: courses.map((course) => DropdownMenuItem(
                value: course,
                child: Text(course),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  selectedCourse = val;
                });
              },
            ),
            const SizedBox(height: 10),

            // Year Dropdown
            DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: InputDecoration(labelText: 'Select Year'),
              items: years.map((year) => DropdownMenuItem(
                value: year,
                child: Text(year),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  selectedYear = val;
                });
              },
            ),
            const SizedBox(height: 10),

            // Section Dropdown
            DropdownButtonFormField<String>(
              value: selectedSection,
              decoration: InputDecoration(labelText: 'Select Section'),
              items: sections.map((section) => DropdownMenuItem(
                value: section,
                child: Text(section),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  selectedSection = val;
                  loadStudents();
                });
              },
            ),
            const SizedBox(height: 20),

            // Student list with switches
            if (students.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      title: Text(student['name']),
                      trailing: Switch(
                        value: attendanceMap[student['id']] ?? false,
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
                label: 'Submit Attendence',
              ),
          ],
        ),
      ),
    );
  }
}
