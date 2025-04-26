import 'dart:developer';
import 'auth_service.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:department/home_screen.dart';
import 'package:department/widgets/button.dart';
import 'package:department/widgets/textfield.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _firestore = FirebaseFirestore.instance;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _rollNo = TextEditingController();


  String _selectedRole = 'Student';
  final List<String> _roles = ['Student', 'Teacher', 'HOD'];

  String _errorMessage = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _rollNo.dispose();
    super.dispose();
  }
  String? _selectedCourse;
  String? _selectedSem;
  String? _selectedSection;

  final List<String> _courses = ['Civil Engineering','Computer Science', 'Electronics & Communication', 'Electrical', 'Mechanical Engineering'];
  final List<String> _semesters = ['1st Semester', '2nd Semester', '3rd Semester', '4th Semester', '5th Semester', '6th Semester', '7th Semester', '8th Semester'];
  final List<String> _sections = ['12', '34', '56','78'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                "Signup",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),

              CustomTextField(
                hint: "Enter Name",
                label: "Name",
                controller: _name,
              ),
              const SizedBox(height: 20),

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

              // // 👇 Show Roll No. field only if Student is selected
              // if (_selectedRole == 'Student') ...[
              //   CustomTextField(
              //     hint: "Enter Roll No.",
              //     label: "Roll No.",
              //     controller: _rollNo,
              //   ),
              //   const SizedBox(height: 20),
              // ],

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Role",
                  border: OutlineInputBorder(),
                ),
                value: _selectedRole,
                items: _roles
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                    if (_selectedRole != 'Student') {
                      _rollNo.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // 👇 Show Roll No. field only if Student is selected
              if (_selectedRole == 'Student') ...[
                CustomTextField(
                  hint: "Enter Roll No.",
                  label: "Roll No.",
                  controller: _rollNo,
                ),
                const SizedBox(height: 20),
              ],
              if (_selectedRole == 'Student') ...[
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Course",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCourse,
                  items: _courses.map((course) => DropdownMenuItem(
                    value: course,
                    child: Text(course),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Year",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSem,
                  items: _semesters.map((year) => DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSem = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Section",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSection,
                  items: _sections.map((section) => DropdownMenuItem(
                    value: section,
                    child: Text(section),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSection = value!;
                    });
                  },
                ),
              ],

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
                label: "Signup",
                onPressed: _signup,
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  InkWell(
                    onTap: () => goToLogin(context),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  goToHome(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );

  _signup() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      final role = _selectedRole.toLowerCase();

      final user = await _auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
        name: _name.text.trim(),
        role: role,
      );

      if (user != null) {
        // Store extra data
        Map<String, dynamic> userData = {
          'uid': user.uid,
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'role': role,
        };

        // Add rollNo for students only
        if (role == 'student') {
          userData.addAll({
            'rollNo': _rollNo.text.trim(),
            'course': _selectedCourse,
            'year': _selectedSem,
            'section': _selectedSection,
          });
        }

        await _firestore.collection('users').doc(user.uid).set(userData);

        log("User Created & Saved Successfully");
        goToHome(context);
      }
    } catch (e) {
      log("Signup Error: $e");
      setState(() {
        _errorMessage = e.toString().split('] ').last;
      });
    }
  }
}
