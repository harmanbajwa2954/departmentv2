import 'package:flutter/material.dart';

class StudentAttendanceUI extends StatelessWidget {
  const StudentAttendanceUI({super.key});

  final List<Map<String, dynamic>> mockAttendance = const [
    {
      'subject': 'Machine Learning',
      'total': 20,
      'present': 17,
      'absent': 3,
    },
    {
      'subject': 'Cloud Computing',
      'total': 18,
      'present': 10,
      'absent': 8,
    },
    {
      'subject': 'Flutter Development',
      'total': 22,
      'present': 20,
      'absent': 2,
    },
    {
      'subject': 'Compiler Design',
      'total': 16,
      'present': 5,
      'absent': 11,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: mockAttendance.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final subject = mockAttendance[index];
            final percent = (subject['present'] / subject['total']) * 100;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['subject'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total: ${subject['total']}"),
                        Text("Present: ${subject['present']}"),
                        Text("Absent: ${subject['absent']}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.grey[300],
                      color: percent >= 75 ? Colors.green : Colors.redAccent,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${percent.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: percent >= 75 ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
