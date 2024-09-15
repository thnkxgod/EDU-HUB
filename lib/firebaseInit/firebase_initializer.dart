import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

// Replace these options with your Firebase project's configuration
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDksDrNk78Uz55JsxnIQwQ5EeUg_Bz0Vh0',  // Replace with your actual API key
  appId: '1:399338951746:android:ef9ef6542371b02b24c9db',  // Replace with your actual App ID
  messagingSenderId: '399338951746',  // Replace with your messaging sender ID
  projectId: 'edhub-auth',  // Replace with your project ID
  storageBucket: 'edhub-auth.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID',  // Replace with your measurement ID if needed
  authDomain: 'edhub-auth.firebaseapp.com',  // Optional, for web apps
);

Future<void> initializeFirebase() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the specified options
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
}