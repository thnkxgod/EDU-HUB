import 'package:EduHub/selectRolePage.dart';
import 'package:flutter/material.dart';
import 'firebaseInit/firebase_initializer.dart'; // Ensure Firebase is initialized
import 'home.dart'; // Home screen
import 'login.dart'; // Login screen
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures services are initialized before runApp
  await initializeFirebase(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edu Hub',
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : SelectRolePage(user: FirebaseAuth.instance.currentUser!), // Show HomePage if already signed in
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) {
          final user = FirebaseAuth.instance.currentUser!;
          return HomePageScreen(user: user); // Ensure User is passed to HomePage
        },
      },
    );
  }
}
