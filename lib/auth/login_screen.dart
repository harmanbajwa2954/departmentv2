import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'signup_screen.dart';
import 'package:department/home_screen.dart';
import 'package:department/widgets/button.dart';
import 'package:department/widgets/textfield.dart';
import 'package:department/dashboards/student_dashboard.dart';
import 'package:department/dashboards/teacher_dashboard.dart';
import 'package:department/dashboards/hod_dashboard.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _role;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _email.clear();
        _password.clear();
        setState(() {
          _role = null;
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Computer Science Department (UCOE), Punjabi University",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                "Login",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500, color: Colors.black),
              ),
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
                controller: _password,
                isPassword: true,
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: "Login",
                onPressed: _login,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.black)),
                  InkWell(
                    onTap: () => goToSignup(context),
                    child: const Text(
                      "Signup",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void goToDashboard(BuildContext context, String role, {String? name, String? rollNo}) {
    switch (role) {
      case "Student":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboard(
              name: name ?? 'Student',
              rollNo: rollNo ?? 'Unknown',
            ),
          ),
        );
        break;
      case "Teacher":
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TeacherDashboard()));
        break;
      case "HOD":
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HODDashboard()));
        break;
      default:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  Future<void> _login() async {
    final user = await _auth.loginUserWithEmailAndPassword(_email.text.trim(), _password.text.trim());

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
        final data = doc.data();

        if (data == null) {
          throw Exception("User data not found.");
        }

        final role = data['role'];
        final name = data['name'];
        final rollNo = data['rollNo'];

        if (role != null) {
          _role = role;
          log("Logged in as $_role");

          if (role == "Student") {
            goToDashboard(context, role, name: name, rollNo: rollNo);
          } else {
            goToDashboard(context, role);
          }
        } else {
          log("Role not found in database.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User role not found in database."), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        log("Error fetching user role: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect credentials. Signup to create an account first."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
