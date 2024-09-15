// import 'package:flutter/material.dart';
// import 'auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _aadharController = TextEditingController(); // New controller for Aadhar
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _dobController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _aadharController.dispose(); // Dispose of the new controller
//     super.dispose();
//   }
//
//   void _register() async {
//     final name = _nameController.text.trim();
//     final dob = _dobController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final aadhar = _aadharController.text.trim(); // Get Aadhar number
//
//     if (name.isEmpty || dob.isEmpty || email.isEmpty || password.isEmpty || aadhar.isEmpty) {
//       print('Please fill in all fields');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill in all fields'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     User? user = await _authService.registerWithEmail(email, password);
//     if (user != null) {
//       print('Registered: ${user.email}');
//       // Save additional user details including Aadhar number
//       await _authService.saveUserDetails(user.uid, name, dob, aadhar);
//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Registration successful!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       // Navigate to the Home screen or another appropriate screen
//     } else {
//       print('Failed to register');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to register'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: Center(//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.black, Colors.red],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Register",
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.06,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildTextField(_nameController, 'Name'),
//               const SizedBox(height: 20),
//               _buildTextField(_dobController, 'Date of Birth (DD/MM/YYYY)'),
//               const SizedBox(height: 20),
//               _buildTextField(_emailController, 'Email'),
//               const SizedBox(height: 20),
//               _buildTextField(_passwordController, 'Password', obscureText: true),
//               const SizedBox(height: 20),
//               _buildTextField(_aadharController, 'Aadhar Card Number'), // New Aadhar text field
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _register,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(
//                     vertical: screenWidth * 0.04,
//                     horizontal: screenWidth * 0.08,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   'Register',
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.045,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return TextField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         hintText: hintText,
//         filled: true,
//         fillColor: Colors.grey[200],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           vertical: screenWidth * 0.04,
//           horizontal: screenWidth * 0.04,
//         ),
//       ),
//     );
//   }
// }
