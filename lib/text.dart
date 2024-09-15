




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncrementViewCountButton extends StatefulWidget {
  final String videoId; // Pass the video ID to identify the correct document

  const IncrementViewCountButton({super.key, required this.videoId});

  @override
  _IncrementViewCountButtonState createState() => _IncrementViewCountButtonState();
}

class _IncrementViewCountButtonState extends State<IncrementViewCountButton> {
  int _viewCount = 0; // Local state to show view count after increment

  // Function to increment the viewCount field in Firestore
  Future<void> incrementViewCount() async {
    try {
      // Get the document from Firestore by videoId
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('videos').doc(widget.videoId).get();

      // Check if the document exists
      if (doc.exists) {
        // Update the document by incrementing the viewCount field by 1
        await FirebaseFirestore.instance.collection('videos').doc(widget.videoId).update({
          'viewCount': FieldValue.increment(1),
        });

        // Retrieve the updated view count and update the state to display it locally
        DocumentSnapshot updatedDoc = await FirebaseFirestore.instance.collection('videos').doc(widget.videoId).get();
        setState(() {
          _viewCount = updatedDoc['viewCount'];
        });

        print('View count incremented successfully to $_viewCount.');
      } else {
        print('Document with videoId: ${widget.videoId} does not exist.');
      }
    } catch (e) {
      print('Error updating view count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await incrementViewCount();
      },
      child: Text('Increment View Count (Current: $_viewCount)'),
    );
  }
}







// void main(){
//
//
//   // String name = "Rajesh";
//   //
//   // print("hi $name how are you..!");
//   // print('''hey i am currently
//   //     living in
//   //     Dehradun''');
//   // print("I have \$12 in my account and \nthis is the length of your name ${name.length} words");
//
//   // var v = '126';
//   // print(v.runtimeType);
//
//   // final tt = DateTime.now();
//   // const ttt=10;
//   // print(tt);
//   // print(ttt);
//
//   // var naam = null;
//   // String? nm;
//   // print(nm?.length??'rak');
//   // // print("value of nm is ${nm = "rajesh"}");
//   // // print(nm.length);
//   // //
//   // // print(nm);
//   //
//   // var name = 'suraesh';
//   // var val = name.startsWith('r')?'value is rajesh ': 'value is not rajehs';
//   // print(val);
//
//
// //   List<String> l = ['hi','hii','hiii','hii...!','hy','hello','hlw'];
// //   var typ='hlw';
// //
// //   if(l.contains(typ))
// //   {print("hii.. Sir!");
// //   }
// //   else{
// //     print("bye..");
// //   }
// //
// // }
// //
// // ---------------------
//
// //
// // import 'package:flutter/material.dart';
// // import 'auth_service.dart'; // Import your authentication service
// // import 'package:firebase_auth/firebase_auth.dart';
// //
// //
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});
// //
// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }
// //
// // class _LoginScreenState extends State<LoginScreen> {
// //   final AuthService _authService = AuthService();
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //
// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _signInWithEmail() async {
// //     final email = _emailController.text.trim();
// //     final password = _passwordController.text.trim();
// //
// //     User? user = await _authService.signInWithEmail(email, password);
// //     if (user != null) {
// //       print('Signed in: ${user.email}');
// //       // Navigate to the Home screen or show success message
// //     } else {
// //       print('Failed to sign in with email and password');
// //     }
// //   }
// //
// //   void _signInWithGoogle() async {
// //     User? user = await _authService.signInWithGoogle();
// //     if (user != null) {
// //       print('Signed in with Google: ${user.email}');
// //       // Navigate to the Home screen or show success message
// //     } else {
// //       print('Failed to sign in with Google');
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     double screenWidth = MediaQuery.of(context).size.width;
// //
// //     return Scaffold(
// //       body: Center(
// //         child: Container(
// //           padding: const EdgeInsets.all(16.0),
// //           decoration: const BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [Colors.black, Colors.red],
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //             ),
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 "Sign in",
// //                 style: TextStyle(
// //                   fontSize: screenWidth * 0.06,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               SizedBox(height: 20),
// //               TextField(
// //                 controller: _emailController,
// //                 decoration: InputDecoration(
// //                   hintText: 'Email',
// //                   filled: true,
// //                   fillColor: Colors.grey[200],
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide: BorderSide.none,
// //                   ),
// //                   contentPadding: EdgeInsets.symmetric(
// //                     vertical: screenWidth * 0.04,
// //                     horizontal: screenWidth * 0.04,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 20),
// //               TextField(
// //                 controller: _passwordController,
// //                 obscureText: true,
// //                 decoration: InputDecoration(
// //                   hintText: 'Password',
// //                   filled: true,
// //                   fillColor: Colors.grey[200],
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     borderSide: BorderSide.none,
// //                   ),
// //                   contentPadding: EdgeInsets.symmetric(
// //                     vertical: screenWidth * 0.04,
// //                     horizontal: screenWidth * 0.04,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: _signInWithEmail,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blue,
// //                   padding: EdgeInsets.symmetric(
// //                     vertical: screenWidth * 0.04,
// //                     horizontal: screenWidth * 0.08,
// //                   ),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                 ),
// //                 child: Text(
// //                   'Sign in with Email',
// //                   style: TextStyle(
// //                     fontSize: screenWidth * 0.045,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: _signInWithGoogle,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.red,
// //                   padding: EdgeInsets.symmetric(
// //                     vertical: screenWidth * 0.04,
// //                     horizontal: screenWidth * 0.08,
// //                   ),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                 ),
// //                 child: Text(
// //                   'Sign in with Google',
// //                   style: TextStyle(
// //                     fontSize: screenWidth * 0.045,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // var nm=p();
// // print(nm.$1);
// // print(nm.$2);
// //
// // printname(123454, name: 'rajesh', gender: 'male');
//
//  // final b = printStuff();
//  // print(b.age);
//  // print(b.nm);
//
//
// // final st = printFun();
// // st();
// //
// // (){
// //   print('yoo');
// // }
// //
// // ();
//
//
// var c = Cookies(50,'gol');
//
// c.size=5;
// print(c.size);
// print(c.shape);
//
// }
//
// //========================================================================================
// class Cookies{
//   final String? shape;
//   int? size;
//   Cookies(this.size, this.shape){
//     baking();
//   }
//
//   void baking(){
//     print('${size} size of cookies is baking');
//   }
// }
//
//
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// //name arguments and positional arguments
//
// // void printname(int? roll ,{required String name ,int? age ,required String gender}){
// //   print(name);
// //   print(gender);
// //   print(roll);
// //
// // }
//
// // (int, String) p() {
// //   return (2, "rajjujgh");
// // }
//
// //
// // ({int age, String nm}) printStuff(){
// //   return (nm: 'rajesgh',age: 56);
// //  }
//
// // Function printFun(){
// //   return (){
// //     print('yooo');
// //   };
// // }