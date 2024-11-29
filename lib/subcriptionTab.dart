// Subscription Tab Widget
import 'package:EduHub/videoTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubscriptionTab extends StatelessWidget {
  const SubscriptionTab({Key? key}) : super(key: key);

  Future<List<String>> _getUserSubscriptions() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        // Retrieve subscriptions array
        return List<String>.from(userDoc['subscriptions'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching subscriptions: $e');
    }
    return [];
  }

  Stream<List<QueryDocumentSnapshot>> _getSubscribedVideos(
      List<String> subscriptions) {
    if (subscriptions.isEmpty) {
      return Stream.value([]); // Return empty stream if no subscriptions
    }

    return FirebaseFirestore.instance
        .collection('videos')
        .where('userId', whereIn: subscriptions)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getUserSubscriptions(),
      builder: (context, subscriptionSnapshot) {
        if (subscriptionSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (subscriptionSnapshot.hasError) {
          return const Center(child: Text('Error loading subscriptions.'));
        }

        List<String> subscriptions = subscriptionSnapshot.data ?? [];

        return StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: _getSubscribedVideos(subscriptions),
          builder: (context, videoSnapshot) {
            if (videoSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (videoSnapshot.hasError) {
              return const Center(child: Text('Error loading videos.'));
            }

            List<QueryDocumentSnapshot> videos = videoSnapshot.data ?? [];

            if (videos.isEmpty) {
              return const Center(
                  child: Text('No videos from your subscriptions.'));
            }

            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> videoData =
                videos[index].data() as Map<String, dynamic>;

                return VideoTile(
                  videoData: videoData,
                  onVideoTap: (String videoId) async {
                    // Additional behavior if needed
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}