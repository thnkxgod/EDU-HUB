import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'home.dart';
import 'register_screen.dart'; // Import the registration screen
import 'package:animated_text_kit/animated_text_kit.dart'; // Import the package for animation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    super.dispose();
  }

  void _signInWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      print('Signed in with Google: ${user.email}');
      // Navigate to the Home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageScreen(user: user)),
      );
    } else {
      print('Failed to sign in with Google');
      // You can also show an error message to the user here
    }
  }

  // void _navigateToRegister() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const RegisterScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(45.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Typing animation for welcome message
              SizedBox(
                width: screenWidth * 0.8,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      'Welcome to Edu-HUB',
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  repeatForever: true,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "If you are a creator, please register first.\nIf you are a normal user, sign in with Google.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.04,
                    horizontal: screenWidth * 0.08,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Register button
              ElevatedButton(
                onPressed: () {
                  // add the Creator Registration logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.04,
                    horizontal: screenWidth * 0.08,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Register as Creator',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
