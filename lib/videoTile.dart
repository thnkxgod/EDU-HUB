import 'package:EduHub/videoPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart';
import 'videoControl.dart';

class VideoTile extends StatelessWidget {
  final Map<String, dynamic> videoData;
  final Future<void> Function(String videoId) onVideoTap; // Callback parameter

  const VideoTile({
    super.key,
    required this.videoData,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = videoData['title'] ?? 'No Title';
    final String description = videoData['description'] ?? 'No Description';
    final String url = videoData['url'] ?? '';
    final String thumbnailUrl = videoData['thumbnailUrl'] ?? '';

    // Safely retrieve and cast the 'timestamp' field from Firestore
    final Timestamp? timestamp = videoData['timestamp'] as Timestamp?;
    final String userName = videoData['userName'] ?? 'Unknown User';
    final int viewCount = videoData['viewCount'] ?? 0; // Set default view count to 0

    // Format the date if timestamp exists
    String formattedDate = 'Unknown Date';
    if (timestamp != null) {
      final DateTime dateTime = timestamp.toDate();
      formattedDate = DateFormat('yMMMd').format(dateTime);
    }

    return GestureDetector(
      onTap: () async {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          String videoId = videoData['id'] ?? 'defaultVideoId'; // Use 'id' instead of 'videoId'
          String userId = videoData['userId'] ?? 'defaultUserId';

          print("Video ID: $videoId");
          print("User ID: $userId");

          await onVideoTap(videoId);

          if (videoId.isNotEmpty && userId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerWidget(
                  videoUrl: url,
                  videoId: videoId,
                  userId: userId,
                  currentUser: currentUser,
                ),
              ),
            );
          } else {
            print('Invalid videoId or userId');
          }
        } else {
          print('User is not logged in');
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$viewCount views',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 14.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Uploaded by: $userName',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Uploaded on: $formattedDate',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}



