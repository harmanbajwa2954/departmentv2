import 'package:flutter/material.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'hod_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Student';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() {
    String email = emailController.text.trim();

    // Example fallback values – in a real app, fetch from Firestore after login
    String name = email.split('@').first; // e.g., 'john123'
    String rollNo = "CSE123"; // Hardcoded for now

    if (selectedRole == 'Student') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDashboard(name: name, rollNo: rollNo),
        ),
      );
    } else if (selectedRole == 'Teacher') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TeacherDashboard(),
        ),
      );
    } else if (selectedRole == 'HOD/Clerk') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HODDashboard(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedRole,
              onChanged: (newValue) {
                setState(() {
                  selectedRole = newValue!;
                });
              },
              items: ['Student', 'Teacher', 'HOD/Clerk']
                  .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
