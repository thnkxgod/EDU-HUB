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

      final videos = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _userVideos = videos;
      });
    } catch (e) {
      print('Error fetching user videos: $e');
    }
  }

  void _deleteVideo(String videoId) async {
    try {
      await FirebaseFirestore.instance.collection('videos').doc(videoId).delete();
      setState(() {
        _userVideos.removeWhere((video) => video['id'] == videoId);
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
        title: Text('${widget.userName}\'s Channel'),
      ),
      body: ListView.builder(
        itemCount: _userVideos.length,
        itemBuilder: (context, index) {
          final video = _userVideos[index];
          return ListTile(
            title: Text(video['title']),
            subtitle: Text(video['description']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteVideo(video['id']),
            ),
            onTap: () {
              // Navigate to edit page or video details
            },
          );
        },
      ),
    );
  }
}
