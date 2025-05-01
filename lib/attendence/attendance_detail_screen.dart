import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:department/auth/auth_service.dart';

class AttendanceDetailScreen extends StatefulWidget {
  final String subjectClassId;
  final String subjectName;
  final String classInfo;
  final String course;
  final String semester;
  final String section;

  const AttendanceDetailScreen({
    super.key,
    required this.subjectClassId,
    required this.subjectName,
    required this.classInfo,
    required this.course,
    required this.semester,
    required this.section,
  });

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  Map<String, Map<String, dynamic>> attendanceData = {}; // {date: {studentId: status}}
  List<String> sortedDates = [];
  Map<String, String> studentNames = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    try {
      final teacherUid = AuthService().getCurrentUser()?.uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (teacherUid == null) return;

      // Load attendance records
      final recordsSnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(teacherUid)
          .collection('attendance')
          .doc(widget.subjectClassId)
          .collection('records')
          .orderBy(FieldPath.documentId, descending: true)
          .get();

      // Load student names
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('course', isEqualTo: widget.course)
          .where('year', isEqualTo: widget.semester)
          .where('section', isEqualTo: widget.section)
          .get();

      // Map student IDs to names
      studentNames = {
        for (var doc in studentsSnapshot.docs) doc.id: doc['name'] ?? 'Unknown'
      };

      // Process attendance records
      final tempAttendanceData = <String, Map<String, dynamic>>{};
      for (var recordDoc in recordsSnapshot.docs) {
        final date = recordDoc.id;
        final statusMap = recordDoc.data();

        tempAttendanceData[date] = {};
        statusMap.forEach((studentId, status) {
          tempAttendanceData[date]![studentId] = {
            'status': status,
            'name': studentNames[studentId] ?? 'Unknown',
          };
        });
      }

      setState(() {
        attendanceData = tempAttendanceData;
        sortedDates = tempAttendanceData.keys.toList()..sort((a, b) => b.compareTo(a));
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load attendance data')),
      );
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subjectName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.classInfo,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Total Sessions: ${sortedDates.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (attendanceData.isEmpty || studentNames.isEmpty) {
      return const Center(child: Text('No attendance records found'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 16,
        headingRowHeight: 40,
        dataRowMinHeight: 40,
        dataRowMaxHeight: 60,
        columns: [
          const DataColumn(
            label: Text('Roll No.', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...sortedDates.map((date) {
            final shortDate = date.split('-').sublist(1).join('/'); // MM/DD
            return DataColumn(
              label: Tooltip(
                message: date,
                child: Text(shortDate),
              ),
            );
          }).toList(),
        ],
        rows: studentNames.entries.map((entry) {
          final studentId = entry.key;
          final studentName = entry.value;

          return DataRow(
            cells: [
              DataCell(Text(studentName)),
              ...sortedDates.map((date) {
                final status = attendanceData[date]?[studentId]?['status'] ?? '-';
                final isPresent = status == 'Present';

                return DataCell(
                  Container(
                    decoration: BoxDecoration(
                      color: isPresent
                          ? Colors.green[50]
                          : (status == '-' ? null : Colors.red[50]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Center(
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isPresent
                              ? Colors.green
                              : (status == '-' ? Colors.grey : Colors.red),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }


  Widget _buildStatsSection() {
    if (isLoading || attendanceData.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatCard('Total Sessions', sortedDates.length.toString()),
              _buildStatCard('Total Students', studentNames.length.toString()),
              _buildStatCard(
                'Last Session',
                sortedDates.isNotEmpty ? sortedDates.first : 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendanceData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildStatsSection(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDataTable(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}