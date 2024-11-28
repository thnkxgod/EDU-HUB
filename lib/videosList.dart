import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'videoTile.dart'; // Ensure this import is correct

class VideosList extends StatefulWidget {
  final User user;
  final bool isSubscriptionTab;

  const VideosList({super.key, required this.user, required this.isSubscriptionTab});

  @override
  State<VideosList> createState() => _VideosListState();
}

class _VideosListState extends State<VideosList> {
  // Your VideosList logic goes here
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Example item count
      itemBuilder: (context, index) {
        return Text('Video $index'); // Replace with your VideoTile logic
      },
    );
  }
}
