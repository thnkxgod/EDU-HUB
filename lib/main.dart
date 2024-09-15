import 'package:flutter/material.dart';
import 'firebaseInit/firebase_initializer.dart';
import 'home.dart'; // Import your home screen
import 'login.dart'; // Import your login screen
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that plugin services are initialized before runApp.
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
      initialRoute: '/login', // Set the initial route to login
      routes: {
        '/login': (context) => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final user = settings.arguments as User; // Extract user from arguments
          return MaterialPageRoute(
            // builder: (context) => HomePageScreen(user: user),
            builder: (context) => HomePageScreen(user: user),
          );
        }
        return null; // Return null if the route is not found
      },
    );
  }
}
