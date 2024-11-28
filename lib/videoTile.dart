import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart';

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

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String videoId;
  final String userId;
  final User currentUser;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.videoId,
    required this.userId,
    required this.currentUser,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Video Player", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const Center(child: CircularProgressIndicator()),
            VideoControls(controller: _controller),
          ],
        ),
      ),
    );
  }
}

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: () {
                final position = controller.value.position;
                final newPosition = position - const Duration(seconds: 10);
                controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
              },
            ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: () {
                final position = controller.value.position;
                final newPosition = position + const Duration(seconds: 10);
                controller.seekTo(newPosition > controller.value.duration ? controller.value.duration : newPosition);
              },
            ),
            IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: () {
                // Rotation logic
                // To be implemented as required
              },
            ),
          ],
        ),
        VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: Colors.red,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.black12,
          ),
        ),
      ],
    );
  }
}
