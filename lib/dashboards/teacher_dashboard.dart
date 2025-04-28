// import 'package:department/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:department/attendence/teacher_attendence_screen.dart';
import 'package:department/auth/auth_service.dart';
import 'package:department/auth/login_screen.dart';
import 'package:department/attendence/manage_subjects_screen.dart';
import 'package:department/teacher/approve_study_material.dart';
import 'package:department/teacher/review_submissions_screen.dart';
import 'package:department/teacher/attendence_analytics_screen.dart';
import 'package:department/teacher/view_complaints_screen.dart';
// import 'package:department/teacher/TaskNotificationManagerScreen.dart';
import 'package:department/teacher/SendAnnouncements.dart';


class TeacherDashboard extends StatefulWidget {
  final bool advanced;
  const TeacherDashboard({super.key, this.advanced = false});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
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
        title: const Text('Teacher Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('Welcome, Professor!', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Department: Computer Science'),
              ),
            ),
            const SizedBox(height: 20),

            // Timetable Section
            widget.advanced
                ? Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.schedule, color: Colors.blueAccent),
                title: Text('View Timetable'),
                subtitle: Text('Check your lecture schedule'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TimetableScreen())),
              ),
            )
                : SizedBox.shrink(),

            const SizedBox(height: 20),

            // Dashboard Options
            _buildDashboardOption(Icons.event_available, 'Manage Attendance', TeacherMarkAttendanceScreen()),
            _buildDashboardOption(Icons.subject_rounded, 'Add Subjects', ManageSubjectsScreen()),
            _buildDashboardOption(Icons.check_circle, 'Approve Study Materials', UploadStudyMaterialScreen()),
            _buildDashboardOption(Icons.report_problem, 'View Complaints', ViewComplaintsScreen()),
            _buildDashboardOption(Icons.assignment_turned_in, 'Review Student Submissions', ReviewSubmissionsScreen()),
            _buildDashboardOption(Icons.notifications_active, 'Send Announcements', SendAnnouncementsScreen()),
            _buildDashboardOption(Icons.analytics, 'Attendance Analytics (AI)', AttendanceAnalyticsScreen()),
            // _buildDashboardOption(Icons.auto_stories, 'AI-Powered Study Insights', StudyInsightsScreen()),

            // Notifications Section
            widget.advanced
                ? Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.notifications, color: Colors.redAccent),
                title: Text('Recent Notifications'),
                subtitle: Text('New complaint received'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen())),
              ),
            )
                : SizedBox.shrink(),
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
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      ),
    );
  }
}

// Placeholder Screens (Should be implemented separately)
class ApproveMaterialsScreen extends StatelessWidget {
  const ApproveMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Approve Study Materials')));
}


//
// class StudyInsightsScreen extends StatelessWidget {
//   @override
//   // Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('AI-Powered Study Insights')));
// }

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Timetable')));
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Notifications')));
}
