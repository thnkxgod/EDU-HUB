import 'package:EduHub/videoPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart';

class VideoTile extends StatelessWidget {
  final Map<String, dynamic> videoData;
  final Future<void> Function(String videoId) onVideoTap;
  final bool showSubscribeButton; // New parameter to control button visibility

  const VideoTile({
    super.key,
    required this.videoData,
    required this.onVideoTap,
    this.showSubscribeButton = true, // Default is true
  });

  Future<bool> _isSubscribed(String uploaderId) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (userDoc.exists) {
      List<dynamic> subscriptions = userDoc['subscriptions'] ?? [];
      return subscriptions.contains(uploaderId);
    }
    return false;
  }

  Future<void> _subscribeToUser(String uploaderId, BuildContext context) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);

    // Check if the user document exists, if not, create it
    DocumentSnapshot userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'subscriptions': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Created new user document for $currentUserId');
    }

    // Now, update the subscriptions
    await userRef.update({
      'subscriptions': FieldValue.arrayUnion([uploaderId]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Subscribed to ${videoData['userName']}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = videoData['title'] ?? 'No Title';
    final String description = videoData['description'] ?? 'No Description';
    final String url = videoData['url'] ?? '';
    final String thumbnailUrl = videoData['thumbnailUrl'] ?? '';
    final String userId = videoData['userId'] ?? 'defaultUserId';
    final String userName = videoData['userName'] ?? 'Unknown User';
    final int viewCount = videoData['viewCount'] ?? 0;

    final Timestamp? timestamp = videoData['timestamp'] as Timestamp?;
    String formattedDate = 'Unknown Date';
    if (timestamp != null) {
      final DateTime dateTime = timestamp.toDate();
      formattedDate = DateFormat('yMMMd').format(dateTime);
    }

    return GestureDetector(
      onTap: () async {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          String videoId = videoData['id'] ?? 'defaultVideoId';

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
          }
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$viewCount views',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                  if (showSubscribeButton)
                    FutureBuilder<bool>(
                      future: _isSubscribed(userId),
                      builder: (context, snapshot) {
                        final isSubscribed = snapshot.data ?? false;

                        return ElevatedButton(
                          onPressed: isSubscribed
                              ? null // Disable the button if already subscribed
                              : () async {
                            try {
                              await _subscribeToUser(userId, context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error adding subscription: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSubscribed ? Colors.grey : Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Text(
                            isSubscribed ? 'Subscribed' : 'Subscribe',
                            style: const TextStyle(fontSize: 12.0, color: Colors.white),
                          ),
                        );
                      },
                    ),
                ],
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


