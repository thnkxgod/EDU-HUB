import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'videoTitle.dart'; // Ensure this is the correct import
import 'CreatorScreen.dart';
import 'channel_page.dart';

class HomePageScreen extends StatefulWidget {
  final User user;

  const HomePageScreen({super.key, required this.user});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _videos = []; // List to hold video data

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchInitialVideos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
      _fetchMoreVideos();
    }
  }

  Future<void> _fetchInitialVideos() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('videos')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final newVideos = snapshot.docs.map((doc) {
        final data = doc.data(); // Already of type Map<String, dynamic>
        return {
          "title": data['title'] ?? 'No Title',
          "description": data['description'] ?? 'No Description',
          "url": data['url'] ?? 'https://via.placeholder.com/150',
          "thumbnailUrl": data['thumbnailUrl'] ?? 'https://via.placeholder.com/150',
          "userName": data['userName'] ?? 'Unknown User',
          "viewCount": data['viewCount'] ?? 0, // Fetch the viewCount field
          "timestamp": data['timestamp'] ?? Timestamp.now(),
          "id": doc.id,
        };
      }).toList();

      setState(() {
        _videos = newVideos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching initial videos: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMoreVideos() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final lastVideoId = _videos.isNotEmpty ? _videos.last['id'] : null;
      final query = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('timestamp', descending: true)
          .limit(5);

      if (lastVideoId != null) {
        final lastDocument = await FirebaseFirestore.instance.collection('videos').doc(lastVideoId).get();
        query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      final moreVideos = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "title": data['title'] ?? 'No Title',
          "description": data['description'] ?? 'No Description',
          "url": data['url'] ?? 'https://via.placeholder.com/150',
          "thumbnailUrl": data['thumbnailUrl'] ?? 'https://via.placeholder.com/150',
          "userName": data['userName'] ?? 'Unknown User',
          "viewCount": data['viewCount'] ?? 0, // Fetch the viewCount field
          "timestamp": data['timestamp'] ?? Timestamp.now(),
          "id": doc.id,
        };
      }).toList();

      setState(() {
        _videos.addAll(moreVideos);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching more videos: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> incrementViewCount(String videoId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('videos').doc(videoId).get();

      if (doc.exists) {
        print('Document found, proceeding with view count increment.');

        await FirebaseFirestore.instance.collection('videos').doc(videoId).update({
          'viewCount': FieldValue.increment(1),
        });

        print('View count incremented successfully.');
      } else {
        print('Document with videoId: $videoId does not exist.');
      }
    } catch (e) {
      print('Error updating view count: $e');
    }
  }

  Future<void> onWatchVideoButtonTapped(String videoId) async {
    await incrementViewCount(videoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Edu-HUB", style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.email ?? 'No Email',
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (widget.user.displayName != null)
                      Text(
                        widget.user.displayName!,
                        style: const TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                if (widget.user.photoURL != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.photoURL!),
                    radius: 20,
                  ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: Colors.white,
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    } catch (e) {
                      print('Error signing out: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to sign out. Please try again.'),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChannelPage(userId: widget.user.uid, userName: widget.user.displayName ?? 'User'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _videos.length + 1, // Add 1 for the loading indicator
          itemBuilder: (context, index) {
            if (index < _videos.length) {
              return VideoTile(
                videoData: _videos[index],
                onVideoTap: (videoId) async => await onWatchVideoButtonTapped(videoId), // Corrected callback
              );
            } else if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const SizedBox(); // Empty space when not loading more
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatorScreen(user: widget.user)),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
