import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_detail_screen.dart';

class TeacherAttendanceViewScreen extends StatelessWidget {
  const TeacherAttendanceViewScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchTeacherAttendanceRecords() async {
    final teacherUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (teacherUid.isEmpty) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('teachers')
        .doc(teacherUid)
        .collection('attendance')
        .get();

    final records = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final docId = doc.id;
      // Split on FIRST '-' only
      final dashIndex = docId.indexOf(' - ');
      final subject = dashIndex != -1
          ? docId.substring(0, dashIndex)
          : docId;
      final classInfo = dashIndex != -1
          ? docId.substring(dashIndex + 3) // skip ' - '
          : '';
      final parts = classInfo.split('_');

      final course = parts.isNotEmpty ? parts[0] : 'Unknown Course';
      final semester = parts.length > 1 ? parts[1] : 'Unknown Semester';
      final section = parts.length > 2 ? parts[2] : 'Unknown Section';

      // Fetch attendance records
      final recordsCollection = doc.reference.collection('records');
      final allRecordsSnapshot = await recordsCollection.get();
      final totalSessions = allRecordsSnapshot.docs.length;

      String lastDate = 'No records';
      int presentCount = 0;
      int totalStudents = 0;

      if (totalSessions > 0) {
        final latest = await recordsCollection
            .orderBy(FieldPath.documentId, descending: true)
            .limit(1)
            .get();
        lastDate = latest.docs.first.id;
        final data = latest.docs.first.data();
        presentCount = data.values.where((v) => v == 'Present').length;
        totalStudents = data.length;
      }

      records.add({
        'docId': docId,
        'subject': subject,
        'course': course,
        'semester': semester,
        'section': section,
        'lastDate': lastDate,
        'totalSessions': totalSessions,
        'presentCount': presentCount,
        'totalStudents': totalStudents,
      });
    }

    return records;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Subjects")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTeacherAttendanceRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No subjects found."));
          }

          final records = snapshot.data!;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, i) {
              final rec = records[i];
              final classInfo = '${rec['course']} • ${rec['semester']} • Sec ${rec['section']}';
              final percent = rec['totalStudents'] > 0
                  ? (rec['presentCount'] / rec['totalStudents'] * 100).round()
                  : 0;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(rec['subject'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(classInfo),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${rec['totalSessions']} sessions'),
                      Text('$percent%'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceDetailScreen(
                          subjectClassId: rec['docId'],
                          subjectName: rec['subject'],
                          classInfo: classInfo,
                          course: rec['course'],
                          semester: rec['semester'],
                          section: rec['section'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );

        },
      ),
    );
  }
}
