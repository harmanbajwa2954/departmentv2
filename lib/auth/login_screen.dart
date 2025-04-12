import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:department/widgets/button.dart';
import 'package:department/widgets/textfield.dart';
import 'package:department/auth/auth_service.dart';
import 'package:department/auth/signup_screen.dart';

// Dashboards
import 'package:department/dashboards/student_dashboard.dart';
import 'package:department/dashboards/teacher_dashboard.dart';
import 'package:department/dashboards/hod_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text("Login",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),

            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _password,
            ),
            const SizedBox(height: 20),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            CustomButton(
              label: "Login",
              onPressed: _login,
            ),
            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  ),
                  child: const Text(
                    "Signup",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final role = doc['role'];
          final name = doc['name'] ?? 'User';
          final rollNo = doc.data()?['rollNo'] ?? 'N/A';

          if (role == 'student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentDashboard(name: name, rollNo: rollNo),
              ),
            );
          } else if (role == 'teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherDashboard(),
              ),
            );
          } else if (role == 'hod') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HODDashboard(),
              ),
            );
          } else {
            setState(() {
              _errorMessage = "Unknown role: $role";
            });
          }
        } else {
          setState(() {
            _errorMessage = "User record not found in Firestore";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Login failed. Please check your credentials.";
        });
      }
    } catch (e) {
      log("Login Error: $e");
      setState(() {
        _errorMessage = e.toString().split('] ').last;
      });
    }
  }
}
