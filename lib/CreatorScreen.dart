import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For picking video and image files
import 'package:firebase_auth/firebase_auth.dart'; // If using FirebaseAuth


class CreatorScreen extends StatefulWidget {
  final User user;
  const CreatorScreen({super.key, required this.user});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _videoFile;
  File? _thumbnailFile;

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, return.
      return;
    }

    if (_videoFile == null || _thumbnailFile == null) {
      // Show error if video or thumbnail is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both video and thumbnail image.')),
      );
      return;
    }

    try {
      // Upload video to Firebase Storage
      final videoStorageRef = FirebaseStorage.instance.ref().child('videos/${DateTime.now().millisecondsSinceEpoch}');
      final uploadVideoTask = videoStorageRef.putFile(_videoFile!);
      final videoSnapshot = await uploadVideoTask.whenComplete(() => {});
      final videoDownloadUrl = await videoSnapshot.ref.getDownloadURL();

      // Upload thumbnail image to Firebase Storage
      final thumbnailStorageRef = FirebaseStorage.instance.ref().child('thumbnails/${DateTime.now().millisecondsSinceEpoch}');
      final uploadThumbnailTask = thumbnailStorageRef.putFile(_thumbnailFile!);
      final thumbnailSnapshot = await uploadThumbnailTask.whenComplete(() => {});
      final thumbnailDownloadUrl = await thumbnailSnapshot.ref.getDownloadURL();

      // Save video metadata to Firestore
      await FirebaseFirestore.instance.collection('videos').add({
        'url': videoDownloadUrl,
        'thumbnailUrl': thumbnailDownloadUrl,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'userId': widget.user.uid, // Store user ID
        'userName': widget.user.displayName ?? 'Unknown', // Store user name
        'timestamp': FieldValue.serverTimestamp(),
        'viewCount': 0, // Initialize view count to 0
      });

      print('Video and thumbnail uploaded and metadata saved.');

      // Clear the controllers and selected files
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _videoFile = null;
        _thumbnailFile = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video and thumbnail successfully uploaded.')),
      );
    } catch (e) {
      print('Error uploading video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading video: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Upload Video', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickVideo,
                  child: const Text('Select Video'),
                ),
                if (_videoFile != null) ...[
                  const SizedBox(height: 16.0),
                  Text('Selected Video: ${_videoFile!.path.split('/').last}'),
                ],
                ElevatedButton(
                  onPressed: _pickThumbnail,
                  child: const Text('Select Thumbnail Image'),
                ),
                if (_thumbnailFile != null) ...[
                  const SizedBox(height: 16.0),
                  Text('Selected Thumbnail: ${_thumbnailFile!.path.split('/').last}'),
                ],
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _uploadVideo,
                  child: const Text('Upload Video'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
