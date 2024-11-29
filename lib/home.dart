import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'videoTile.dart';
import 'channel_page.dart';

class HomePageScreen extends StatefulWidget {
  final User user;

  const HomePageScreen({super.key, required this.user});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _currentIndex = 0; // To track selected tab
  final List<Widget> _pages = []; // Pages for Home and Subscriptions
  final GlobalKey<VideosListState> _homeListKey = GlobalKey();
  final GlobalKey<VideosListState> _subscriptionsListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initialize pages with VideosList for each tab
    _pages.addAll([
      VideosList(key: _homeListKey, isSubscriptionTab: false),
      VideosList(key: _subscriptionsListKey, isSubscriptionTab: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                'assets/EDU-HUB logo trnsp.png',
                height: 120,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.user.displayName != null)
                      Text(
                        widget.user.displayName!,
                        style: const TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                if (widget.user.photoURL != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChannelPage(
                            userId: widget.user.uid,
                            userName: widget.user.displayName ?? 'User',
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.user.photoURL!),
                      radius: 20,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blue],
            begin: Alignment.centerLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger refresh on the active page
            if (_currentIndex == 0) {
              await _homeListKey.currentState?.refreshVideos();
            } else {
              await _subscriptionsListKey.currentState?.refreshVideos();
            }
          },
          child: _pages[_currentIndex], // Display the selected page
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blue],
            begin: Alignment.centerLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Update selected index
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.subscriptions),
              label: 'Subscriptions',
            ),
          ],
        ),
      ),

    );
  }
}

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
      _fetchMoreVideos();
    }
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('timestamp', descending: true);

      if (widget.isSubscriptionTab) {
        // Fetch only videos from subscribed users
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        List<String> subscribedUserIds = List<String>.from(userDoc['subscriptions'] ?? []);

        query = query.where('userId', whereIn: subscribedUserIds.isEmpty ? ['none'] : subscribedUserIds);
      }

      final snapshot = await query.limit(10).get();
      final videos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "title": data['title'] ?? 'No Title',
          "description": data['description'] ?? 'No Description',
          "url": data['url'] ?? 'https://via.placeholder.com/150',
          "thumbnailUrl": data['thumbnailUrl'] ?? 'https://via.placeholder.com/150',
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
      print('Error fetching videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreVideos() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final lastVideoId = _videos.isNotEmpty ? _videos.last['id'] : null;
      Query query = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('timestamp', descending: true)
          .limit(5);

      if (lastVideoId != null) {
        final lastDocument = await FirebaseFirestore.instance
            .collection('videos')
            .doc(lastVideoId)
            .get();
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final moreVideos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "title": data['title'] ?? 'No Title',
          "description": data['description'] ?? 'No Description',
          "url": data['url'] ?? 'https://via.placeholder.com/150',
          "thumbnailUrl": data['thumbnailUrl'] ?? 'https://via.placeholder.com/150',
          "userName": data['userName'] ?? 'Unknown User',
          "viewCount": data['viewCount'] ?? 0,
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
      itemCount: _videos.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _videos.length) {
          final video = _videos[index];
          return VideoTile(
            videoData: video,
            onVideoTap: (videoId) async => await FirebaseFirestore.instance
                .collection('videos')
                .doc(videoId)
                .update({'viewCount': FieldValue.increment(1)}),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
class SubscriptionTab extends StatelessWidget {
  const SubscriptionTab({Key? key}) : super(key: key);

  Future<List<String>> _getUserSubscriptions() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Retrieve the subscriptions array from the user's Firestore document
      List<String> subscriptions =
      List<String>.from(userDoc['subscriptions'] ?? []);
      return subscriptions;
    } else {
      return [];
    }
  }

  Stream<List<QueryDocumentSnapshot>> _getSubscribedVideos(
      List<String> subscriptions) {
    if (subscriptions.isEmpty) {
      return Stream.value([]); // Return an empty stream if no subscriptions
    }

    return FirebaseFirestore.instance
        .collection('videos')
        .where('userId', whereIn: subscriptions)
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
                    // Add any additional behavior here if needed
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
