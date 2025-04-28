import 'package:flutter/material.dart';
// import 'package:department/widgets/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendAnnouncementsScreen extends StatefulWidget {
  @override
  _SendAnnouncementsScreenState createState() => _SendAnnouncementsScreenState();
}

class _SendAnnouncementsScreenState extends State<SendAnnouncementsScreen> {
  final TextEditingController _announcementController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitAnnouncement() async {
    final String announcementText = _announcementController.text.trim();

    // Check if empty
    if (announcementText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter an announcement!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Firestore write
      await FirebaseFirestore.instance.collection('announcements').add({
        'announcement': announcementText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Confirm success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Announcement sent successfully!')),
      );

      _announcementController.clear();
    } catch (e) {
      // Catch and show error
      print('❌ Error writing to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to send announcement.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Announcements')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your announcement:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _announcementController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your announcement here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitAnnouncement,
                icon: const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Sending...' : 'Send Announcement'),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(color: Colors.white),
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
