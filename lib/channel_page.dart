import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChannelPage extends StatefulWidget {
  final String userId;
  final String userName;

  const ChannelPage({super.key, required this.userId, required this.userName});

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  List<Map<String, dynamic>> _userVideos = [];

  @override
  void initState() {
    super.initState();
    _fetchUserVideos();
  }

  Future<void> _fetchUserVideos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('videos')
          .where('userId', isEqualTo: widget.userId)
          .get();

      // Add 'id' field to each video document
      final videos = snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id, // Use 'id' consistently across the app
      }).toList();

      setState(() {
        _userVideos = videos;
      });
    } catch (e) {
      print('Error fetching user videos: $e');
    }
  }

  void _deleteVideo(String documentId) async {
    try {
      print('Deleting video with ID: $documentId'); // Debugging log
      await FirebaseFirestore.instance.collection('videos').doc(documentId).delete();
      setState(() {
        _userVideos.removeWhere((video) => video['id'] == documentId);
      });
    } catch (e) {
      print('Error deleting video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${widget.userName}\'s Channel',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _userVideos.isEmpty
          ? const Center(
        child: Text(
          'No videos found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _userVideos.length,
        itemBuilder: (context, index) {
          final video = _userVideos[index];
          return ListTile(
            title: Text(video['title'] ?? 'No Title'),
            subtitle: Text(video['description'] ?? 'No Description'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteVideo(video['id']),
            ),
            onTap: () {
              // Add navigation to the video details or edit page if required
              print('Tapped on video: ${video['id']}');
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Return to Home Page
        },
        child: const Icon(Icons.home),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
