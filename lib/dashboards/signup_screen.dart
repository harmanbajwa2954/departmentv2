// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   String selectedRole = 'Student';
//
//   Future<void> _signup() async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//
//       // Store additional user data in Firestore
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'name': nameController.text.trim(),
//         'email': emailController.text.trim(),
//         'role': selectedRole,
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Signup successful! Please login.")),
//       );
//       Navigator.pushReplacementNamed(context, '/login');
//     } catch (e) {
//       print("Signup failed: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Signup failed: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Signup')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Full Name'),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             DropdownButton<String>(
//               value: selectedRole,
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedRole = newValue!;
//                 });
//               },
//               items: ['Student', 'Teacher', 'HOD/Clerk']
//                   .map((role) => DropdownMenuItem(
//                 value: role,
//                 child: Text(role),
//               ))
//                   .toList(),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _signup,
//               child: Text('Signup'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, '/login');
//               },
//               child: Text('Already have an account? Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
