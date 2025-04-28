import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:department/widgets/button.dart';

class TaskNotificationManagerScreen extends StatefulWidget {
  final String rollNo;

  const TaskNotificationManagerScreen({super.key, required this.rollNo});

  @override
  State<TaskNotificationManagerScreen> createState() =>
      _TaskNotificationManagerScreenState();
}

class _TaskNotificationManagerScreenState
    extends State<TaskNotificationManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  final TextEditingController _performanceController = TextEditingController();

  void _addTask() async {
    if (_taskTitleController.text.isEmpty) return;

    await _firestore.collection('tasks').add({
      'title': _taskTitleController.text,
      'description': _taskDescController.text,
      'createdBy': widget.rollNo,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _taskTitleController.clear();
    _taskDescController.clear();
    Navigator.of(context).pop();
  }

  void _submitPerformance() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Submit Performance"),
        content: TextField(
          controller: _performanceController,
          maxLines: 5,
          decoration: const InputDecoration(
              hintText: "Describe your performance/activity..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_performanceController.text.trim().isEmpty) return;

              await _firestore.collection('submissions').add({
                'rollNo': widget.rollNo,
                'performance': _performanceController.text.trim(),
                'timestamp': FieldValue.serverTimestamp(),
              });

              _performanceController.clear();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Performance submitted successfully")),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskTitleController,
                decoration: const InputDecoration(hintText: "Task Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _taskDescController,
                decoration: const InputDecoration(hintText: "Task Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            CustomButton(
              onPressed: _addTask,
              label: "Add Task",
            ),
          ],
        );
      },
    );
  }


  String _timeAgo(Timestamp timestamp) {
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    return "${diff.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Task & Notification Manager"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Tasks", icon: Icon(Icons.task)),
              Tab(text: "Notifications", icon: Icon(Icons.notifications)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tasks')
                  .where('createdBy', isEqualTo: widget.rollNo)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tasks found.'));
                }

                final tasks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        title: Text(task['title']),
                        subtitle: Text(task['description']),
                        trailing: Checkbox(
                          value: task['status'] == 'done',
                          onChanged: (val) {
                            _firestore.collection('tasks').doc(task.id).update({
                              'status': val! ? 'done' : 'pending',
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('notifications')
                  .where('targetUser', whereIn: ['all', widget.rollNo])
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No notifications found.'));
                }

                final notifications = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final note = notifications[index];
                    return ListTile(
                      leading:
                      const Icon(Icons.notifications, color: Colors.redAccent),
                      title: Text(note['title']),
                      subtitle: Text(note['body']),
                      trailing: Text(
                        note['timestamp'] != null
                            ? _timeAgo(note['timestamp'])
                            : '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'submitPerformance',
              onPressed: _submitPerformance,
              icon: const Icon(Icons.send),
              label: const Text("Submit Performance"),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'addTask',
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add),
              tooltip: 'Add New Task',
            ),
          ],
        ),
      ),
    );
  }
}
