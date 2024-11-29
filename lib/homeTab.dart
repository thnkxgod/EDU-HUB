import 'package:EduHub/videoTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VideosList extends StatefulWidget {
  final bool isSubscriptionTab;

  const VideosList({super.key, required this.isSubscriptionTab});

  @override
  State<VideosList> createState() => VideosListState();
}

class VideosListState extends State<VideosList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _videos = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchVideos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      // Implement pagination if needed
    }
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sort first by viewCount (descending), then by timestamp (descending)
      Query query = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('viewCount', descending: true)
          .orderBy('timestamp', descending: true);

      final snapshot = await query.limit(10).get();
      final videos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "title": data['title'] ?? 'No Title',
          "description": data['description'] ?? 'No Description',
          "url": data['url'] ?? 'https://via.placeholder.com/150',
          "thumbnailUrl": data['thumbnailUrl'] ?? 'https://via.placeholder.com/150',
          "userId": data['userId'] ?? '',
          "userName": data['userName'] ?? 'Unknown User',
          "viewCount": data['viewCount'] ?? 0,
          "timestamp": data['timestamp'] ?? Timestamp.now(),
          "id": doc.id,
        };
      }).toList();

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> refreshVideos() async {
    setState(() => _videos = []); // Clear current videos
    await _fetchVideos(); // Fetch fresh videos
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _videos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videos.isEmpty) {
      return const Center(child: Text('No videos found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return VideoTile(
          videoData: video,
          onVideoTap: (videoId) async {
            // Update the viewCount of the video and re-fetch the list
            await FirebaseFirestore.instance
                .collection('videos')
                .doc(videoId)
                .update({'viewCount': FieldValue.increment(1)});
            // Optionally refresh the videos list after updating view count
            refreshVideos();
          },
        );
      },
    );
  }
}
