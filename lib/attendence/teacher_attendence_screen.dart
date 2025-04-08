import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final String teacherId;

  const TeacherAttendanceScreen({required this.teacherId, Key? key}) : super(key: key);

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Create Tab
  final TextEditingController _sectionNameController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  List<String> _students = [];

  // For Mark Attendance Tab
  String? selectedSectionId;
  Map<String, bool> attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // =================== 🔹 CREATE SECTION TAB 🔹 ===================

  Future<void> createSection() async {
    final sectionName = _sectionNameController.text.trim();

    if (sectionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Section name cannot be empty')));
      return;
    }

    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add at least one student')));
      return;
    }

    try {
      // Create section document
      final sectionRef = await FirebaseFirestore.instance.collection('sections').add({
        'name': sectionName,
        'teacherId': widget.teacherId,
      });

      // Add each student under 'students' subcollection
      for (String studentName in _students) {
        await sectionRef.collection('students').add({'name': studentName});
      }

      // Clear input after success
      _sectionNameController.clear();
      _studentNameController.clear();
      _students.clear();

      setState(() {}); // Update UI

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Section created successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }


  // =================== 🔹 MARK ATTENDANCE TAB 🔹 ===================

  Future<List<Map<String, dynamic>>> fetchSections() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sections')
        .where('teacherId', isEqualTo: widget.teacherId)
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
  }

  Future<List<Map<String, dynamic>>> fetchStudents(String sectionId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sections')
        .doc(sectionId)
        .collection('students')
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
  }

  void markAttendance(String studentId, bool isPresent) {
    setState(() {
      attendanceMap[studentId] = isPresent;
    });
  }

  Future<void> submitAttendance() async {
    final date = DateTime.now().toIso8601String().split('T')[0];
    final batch = FirebaseFirestore.instance.batch();

    attendanceMap.forEach((studentId, isPresent) {
      final attendanceRef = FirebaseFirestore.instance
          .collection('sections')
          .doc(selectedSectionId)
          .collection('students')
          .doc(studentId)
          .collection('attendance')
          .doc(date);

      batch.set(attendanceRef, {
        'status': isPresent ? 'Present' : 'Absent',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance submitted')));
  }

  // =================== 🧱 BUILD UI ===================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Create Class'),
            Tab(text: 'Mark Attendance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Create Class Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _sectionNameController,
                  decoration: InputDecoration(labelText: 'Class/Subject Name'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _studentNameController,
                        decoration: InputDecoration(labelText: 'Student Name'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_studentNameController.text.trim().isNotEmpty) {
                          setState(() {
                            _students.add(_studentNameController.text.trim());
                            _studentNameController.clear();
                          });
                        }
                      },
                    )
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(_students[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _students.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: createSection,
                  child: Text('Create Section'),
                ),
              ],
            ),
          ),

          // Mark Attendance Tab
          Column(
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchSections(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final sections = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('Select Section'),
                      value: selectedSectionId,
                      items: sections.map((section) {
                        return DropdownMenuItem<String>(
                          value: section['id'],
                          child: Text(section['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedSectionId = val;
                          attendanceMap.clear();
                        });
                      },
                    ),
                  );
                },
              ),
              if (selectedSectionId != null)
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchStudents(selectedSectionId!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      final students = snapshot.data!;
                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final status = attendanceMap[student['id']] ?? false;
                          return ListTile(
                            title: Text(student['name']),
                            trailing: Switch(
                              value: status,
                              onChanged: (val) => markAttendance(student['id'], val),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ElevatedButton(
                onPressed: submitAttendance,
                child: Text('Submit Attendance'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sectionNameController.dispose();
    _studentNameController.dispose();
    super.dispose();
  }
}
