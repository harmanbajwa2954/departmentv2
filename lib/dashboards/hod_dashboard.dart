import 'package:flutter/material.dart';

// Import your screen files
import 'package:department/hod/ApproveMaterialsScreen.dart';
import 'package:department/hod/DepartmentInsightsScreen.dart';
import 'package:department/hod/HandleEscalatedComplaintsScreen.dart';
import 'package:department/hod/OverseeTeacherActivityScreen.dart';
import 'package:department/hod/PerformanceReportsScreen.dart';
import 'package:department/hod/SendAnnouncementsScreen.dart';
import 'package:department/auth/auth_service.dart';
import 'package:department/auth/login_screen.dart';

class HODDashboard extends StatefulWidget {
  final bool advanced;
  const HODDashboard({super.key, this.advanced = false});

  @override
  _HODDashboardState createState() => _HODDashboardState();
}

class _HODDashboardState extends State<HODDashboard> {
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
        title: const Text('HOD Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('Welcome, HOD!', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Department: Computer Science'),
              ),
            ),
            const SizedBox(height: 20),

            // Dashboard Options
            _buildDashboardOption(Icons.supervisor_account, 'Oversee Teacher Activity', const OverseeTeachersScreen()),
            _buildDashboardOption(Icons.report_gmailerrorred, 'Handle Escalated Complaints', const EscalatedComplaintsScreen()),
            _buildDashboardOption(Icons.insights, 'View Department Insights', const DepartmentInsightsScreen()),
            _buildDashboardOption(Icons.library_books, 'Approve Study Materials', const ApproveMaterialsScreen()),
            _buildDashboardOption(Icons.analytics, 'Performance Reports & Analytics', const PerformanceReportsScreen()),
            _buildDashboardOption(Icons.notifications_active, 'Send Announcements', const SendAnnouncementsScreen()),

            if (widget.advanced)
              const SizedBox(height: 10),
            // Uncomment when available
            // _buildDashboardOption(Icons.auto_graph, 'AI-Powered Analytics', const AIDepartmentAnalyticsScreen()),
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      ),
    );
  }
}
