import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

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
  bool _showControls = true; // To toggle controls visibility
  bool _isFullscreen = false; // To track fullscreen state
  double _currentSpeed = 1.0; // Playback speed

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() => setState(() {}))
      ..initialize().then((_) {
        setState(() {}); // Update UI when the video is initialized
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    // Ensure to restore portrait orientation when the widget is disposed
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _seekRelative(Duration offset) {
    final newPosition = _controller.value.position + offset;
    _controller.seekTo(newPosition);
  }

  void _changeSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
      _controller.setPlaybackSpeed(speed);
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // Hide system UI
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Restore system UI
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !_isFullscreen
          ? AppBar(
        backgroundColor: Colors.black,
        title: const Text("Video Player", style: TextStyle(color: Colors.white)),
      )
          : null, // Hide AppBar in fullscreen mode
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls), // Toggle controls
        onHorizontalDragUpdate: (details) {
          // Swipe to seek
          final offset = details.delta.dx > 0 ? 10 : -10; // Swipe right/left
          _seekRelative(Duration(seconds: offset));
        },
        child: Center(
          child: _controller.value.isInitialized
              ? Stack(
            alignment: Alignment.bottomCenter, // Aligning the controls at the bottom
            children: [
              // Video player with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.black], // Gradient from blue to black
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              if (_showControls) _buildControls(),
            ],
          )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black.withOpacity(0.5), // Semi-transparent background for the controls
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute controls evenly
        children: [
          IconButton(
            icon: Icon(
              _controller.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: Colors.white,
              size: 48,
            ),
            onPressed: _togglePlayPause,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () => _seekRelative(const Duration(seconds: -10)),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () => _seekRelative(const Duration(seconds: 10)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: _toggleFullscreen,
          ),
          _buildSpeedControl(),
        ],
      ),
    );
  }

  Widget _buildSpeedControl() {
    return PopupMenuButton<double>(
      initialValue: _currentSpeed,
      onSelected: _changeSpeed,
      itemBuilder: (context) => [
        for (var speed in [0.5, 1.0, 1.5, 2.0])
          PopupMenuItem(
            value: speed,
            child: Text("${speed}x"),
          ),
      ],
      child: Row(
        children: [
          const Icon(Icons.speed, color: Colors.white),
          Text("${_currentSpeed}x", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
