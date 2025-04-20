import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Image.asset(
                'lib/assets/ucoe'
                    '.png',
                height: MediaQuery.of(context).size.height * 0.25, // 25% of screen height
                width: MediaQuery.of(context).size.width * 0.8,     // 80% of screen width
                fit: BoxFit.contain,
              ),
            ),

            Text(
              "Welcome Back 👋",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Login to continue",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            CustomTextField(
              hint: "Enter your email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              hint: "Enter your password",
              label: "Password",
              isPassword: true,
              controller: _password,
            ),
            const SizedBox(height: 20),

            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              label: "Login",
              onPressed: _login,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
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
          } else if (role == 'teacher' || role == 'Teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TeacherDashboard()),
            );
          } else if (role == 'hod' || role == 'HOD') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HODDashboard()),
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
          _errorMessage = "Invalid credentials. Please try again.";
        });
      }
    } catch (e) {
      log("Login Error: $e");
      setState(() {
        _errorMessage = e.toString().split('] ').last;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
