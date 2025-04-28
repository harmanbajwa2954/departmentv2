import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:department/widgets/button.dart';


class SendAnnouncementsScreen extends StatefulWidget {
  const SendAnnouncementsScreen({super.key});

  @override
  State<SendAnnouncementsScreen> createState() => _SendAnnouncementsScreenState();
}

class _SendAnnouncementsScreenState extends State<SendAnnouncementsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  void _sendAnnouncement() {
    if (_titleController.text.isNotEmpty && _messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('announcements').add({
        'title': _titleController.text,
        'message': _messageController.text,
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement Sent')));
      _titleController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Announcements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 20),
            CustomButton(onPressed: _sendAnnouncement, label:'Send'),
          ],
        ),
      ),
    );
  }
}
