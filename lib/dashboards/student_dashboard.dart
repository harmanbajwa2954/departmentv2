import 'package:department/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:department/auth/auth_service.dart';
import 'package:department/auth/login_screen.dart';
import 'package:department/student/study_material_screen.dart';
import 'package:department/student/complaint_screen.dart';
import 'package:department/student/lost_found_screen.dart';
import 'package:department/attendence/student_attendence_screen.dart';

class StudentDashboard extends StatefulWidget {
  final bool advanced;
  final String name;
  final String rollNo;

  const StudentDashboard({
    super.key,
    this.advanced = false,
    required this.name,
    required this.rollNo,
  });

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final AuthService _authService = AuthService();

  void _signOut() async {
    await _authService.signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  'Welcome, ${widget.name}!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    'Roll No: ${widget.rollNo}\nDepartment: Computer Science'),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 20),

            // Timetable Section
            widget.advanced
                ? Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.schedule,
                    color: Colors.blueAccent),
                title: const Text('View Timetable'),
                subtitle: const Text('Check your upcoming classes'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimetableScreen(),
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),

            // Dashboard Options
            _buildDashboardOption(Icons.calendar_today, 'View Attendance',
                AttendanceScreen()),
            _buildDashboardOption(
                Icons.menu_book,
                'Study Materials',
                StudyMaterialsScreen(name: widget.name)),
            _buildDashboardOption(
                Icons.report_problem,
                'Register Complaint',
                ComplaintScreen(name: widget.name, rollNo: widget.rollNo)),
            _buildDashboardOption(
                Icons.search,
                'Lost & Found',
                LostFoundScreen(name: widget.name, rollNo: widget.rollNo)),
            _buildDashboardOption(Icons.task, 'Task Manager & Notifications',
                TaskManagerScreen()),
            _buildDashboardOption(Icons.trending_up,
                'Attendance Prediction (AI)', AttendancePredictionScreen()),
            _buildDashboardOption(Icons.school, 'Smart Study Material (AI)',
                SmartStudyMaterialScreen()),

            // Notifications Section
            widget.advanced
                ? Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.notifications,
                    color: Colors.redAccent),
                title: const Text('Recent Notifications'),
                subtitle: const Text('New assignment uploaded'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  // Helper function to create dashboard options
  Widget _buildDashboardOption(IconData icon, String title, Widget page) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)),
      ),
    );
  }
}

// Placeholder Screens
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(
          title: const Text('Attendance Tracking')
          ),
          body: Center(
            child:
              CustomButton(label: 'ViewAttendence', onPressed : (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentAttendanceUI()),
                );
              }),
          ),

      );
}

class TaskManagerScreen extends StatelessWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Task Manager & Notifications')));
}

class AttendancePredictionScreen extends StatelessWidget {
  const AttendancePredictionScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('AI Attendance Prediction')));
}

class SmartStudyMaterialScreen extends StatelessWidget {
  const SmartStudyMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('Smart Study Material (AI)')));
}

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('Timetable')));
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('Notifications')));
}
