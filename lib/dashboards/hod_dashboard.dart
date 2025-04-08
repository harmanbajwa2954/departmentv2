import 'package:flutter/material.dart';

class HODDashboard extends StatefulWidget {
  final bool advanced;
  const HODDashboard({super.key, this.advanced = false});

  @override
  _HODDashboardState createState() => _HODDashboardState();
}

class _HODDashboardState extends State<HODDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOD Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
                title: Text('Welcome, HOD!', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Department: Computer Science'),
              ),
            ),
            const SizedBox(height: 20),

            // Notifications Section
            widget.advanced
                ? Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.notifications, color: Colors.redAccent),
                title: Text('Recent Notifications'),
                subtitle: Text('New report generated'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen())),
              ),
            )
                : SizedBox.shrink(),

            const SizedBox(height: 20),

            // Dashboard Options
            _buildDashboardOption(Icons.supervisor_account, 'Oversee Teacher Activity', OverseeTeachersScreen()),
            _buildDashboardOption(Icons.report_gmailerrorred, 'Handle Escalated Complaints', EscalatedComplaintsScreen()),
            _buildDashboardOption(Icons.insights, 'View Department Insights', DepartmentInsightsScreen()),
            _buildDashboardOption(Icons.library_books, 'Approve Study Materials', ApproveMaterialsScreen()),
            _buildDashboardOption(Icons.analytics, 'Performance Reports & Analytics', PerformanceReportsScreen()),
            _buildDashboardOption(Icons.notifications_active, 'Send Announcements', SendAnnouncementsScreen()),

            // AI Analytics Section
            widget.advanced
                ? Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.auto_graph, color: Colors.green),
                title: Text('AI-Powered Analytics'),
                subtitle: Text('Get intelligent insights on department performance'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AIDepartmentAnalyticsScreen())),
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
class OverseeTeachersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Oversee Teacher Activity')));
}

class EscalatedComplaintsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Handle Escalated Complaints')));
}

class DepartmentInsightsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('View Department Insights')));
}

class ApproveMaterialsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Approve Study Materials')));
}

class PerformanceReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Performance Reports & Analytics')));
}

class SendAnnouncementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Send Announcements')));
}

class AIDepartmentAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('AI-Powered Department Analytics')));
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Notifications')));
}
