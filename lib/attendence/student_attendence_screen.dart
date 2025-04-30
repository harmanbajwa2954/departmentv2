import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentAttendanceUI extends StatefulWidget {
  const StudentAttendanceUI({super.key});

  @override
  State<StudentAttendanceUI> createState() => _StudentAttendanceUIState();
}

class _StudentAttendanceUIState extends State<StudentAttendanceUI> {
  bool isLoading = true;
  List<Map<String, dynamic>> subjectAttendance = [];

  @override
  void initState() {
    super.initState();
    fetchStudentAttendance();
  }

  Future<void> fetchStudentAttendance() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ No logged-in user');
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final studentData = userDoc.data();

      if (studentData == null) {
        debugPrint('❌ Student document not found for uid: ${user.uid}');
        return;
      }

      final course = studentData['course'];
      final semester = studentData['year']; // ⚠️ NOT 'semester' since you're storing it as 'year'
      final section = studentData['section'];

      debugPrint('📌 Course: $course, Semester (from year): $semester, Section: $section');

      final teacherSnapshots = await FirebaseFirestore.instance.collection('teachers').get();
      final List<Map<String, dynamic>> attendanceList = [];

      for (final teacherDoc in teacherSnapshots.docs) {
        final attendanceSnapshot = await teacherDoc.reference.collection('attendance').get();

        for (final subjectDoc in attendanceSnapshot.docs) {
          final docId = subjectDoc.id;
          final dashIndex = docId.indexOf('-');
          if (dashIndex == -1) continue;

          final subjectName = docId.substring(0, dashIndex).trim();
          final classInfo = docId.substring(dashIndex + 1).trim(); // Course_Semester_Section

          final expectedClassInfo = '${course.trim()}_${semester.trim()}_${section.trim()}';
          debugPrint('🔍 Checking: $classInfo == $expectedClassInfo');

          if (classInfo.toLowerCase() != expectedClassInfo.toLowerCase()) continue;

          final records = await subjectDoc.reference.collection('records').get();

          int total = 0;
          int present = 0;

          for (final rec in records.docs) {
            final data = rec.data();
            debugPrint('📄 Record Date: ${rec.id} → ${data[user.uid]}');

            final status = data[user.uid];
            if (status != null) {
              total++;
              if (status == 'Present') present++;
            }
          }

          if (total > 0) {
            attendanceList.add({
              'subject': subjectName,
              'total': total,
              'present': present,
              'absent': total - present,
            });
          }
        }
      }

      setState(() {
        subjectAttendance = attendanceList;
        isLoading = false;
      });

      debugPrint('✅ Attendance fetched: $attendanceList');
    } catch (e) {
      debugPrint('❌ Error fetching student attendance: $e');
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjectAttendance.isEmpty
          ? const Center(child: Text("No attendance records found."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: subjectAttendance.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final subject = subjectAttendance[index];
            final percent = (subject['present'] / subject['total']) * 100;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['subject'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total: ${subject['total']}"),
                        Text("Present: ${subject['present']}"),
                        Text("Absent: ${subject['absent']}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.grey[300],
                      color: percent >= 75 ? Colors.green : Colors.redAccent,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${percent.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: percent >= 75 ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
