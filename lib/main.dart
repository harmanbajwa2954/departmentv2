import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyCDkQeB3Y-uWOKYi9-_LoNWI9xd3wOIeEQ",
          authDomain: "department-70ae6.firebaseapp.com",
          projectId: "department-70ae6",
          storageBucket: "department-70ae6.appspot.com",
          messagingSenderId: "737763175704",
          appId: "1:737763175704:web:e1c6ae03123abe9d34426d",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
