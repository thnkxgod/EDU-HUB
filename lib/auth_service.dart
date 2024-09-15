import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in with email and password: $e');
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error registering with email and password: $e');
      return null;
    }
  }

  // Save additional user details to Firestore
  Future<void> saveUserDetails(String userId, String name, String dob,
      String aadhar) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'dob': dob,
        'aadhar': aadhar, // Save Aadhar number
      });
      print('User details saved to Firestore');
    } catch (e) {
      print('Error saving user details: $e');
    }
  }

  // Sign out
  // Sign out from Firebase and Google Sign-In, and clear cache
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.disconnect(); // Disconnect to clear cache
      await _googleSignIn.signOut(); // Sign out from Google
      print('User signed out from Firebase and Google, and cache cleared');
    } catch (e) {
      print('Error signing out: $e');
    }
  }


  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(
          credential);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

}
