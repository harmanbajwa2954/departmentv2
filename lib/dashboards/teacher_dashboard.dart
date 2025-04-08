import 'package:flutter/material.dart';
import 'package:department/attendence/teacher_attendence_screen.dart';
import 'package:department/auth/auth_service.dart';

class TeacherDashboard extends StatefulWidget {
  final bool advanced;
  const TeacherDashboard({super.key, this.advanced = false});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
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
            _buildDashboardOption(Icons.check_circle, 'Approve Study Materials', ApproveMaterialsScreen()),
            _buildDashboardOption(Icons.event_available, 'Manage Attendance', ManageAttendanceScreen()),
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
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Approve Study Materials')));
}

class ManageAttendanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Attendance')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final currentUser = AuthService().getCurrentUser();
            final teacherId = currentUser?.uid ?? 'unknown'; // fallback just in case

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherAttendanceScreen(teacherId: teacherId),
              ),
            );
          },
          child: Text("Mark Attendance"),
        ),
      ),
    );
  }
}


class ViewComplaintsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('View Complaints')));
}

class ReviewSubmissionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Review Student Submissions')));
}

class SendAnnouncementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Send Announcements')));
}

class AttendanceAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Attendance Analytics (AI)')));
}
//
// class StudyInsightsScreen extends StatelessWidget {
//   @override
//   // Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('AI-Powered Study Insights')));
// }

class TimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Timetable')));
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Notifications')));
}
