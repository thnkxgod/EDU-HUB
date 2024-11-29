import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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