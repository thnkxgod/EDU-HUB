import 'dart:io';
import 'package:EduHub/login.dart';
import 'package:EduHub/selectRolePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _isUploading = false; // Tracks if an upload is in progress

  Future<void> _pickVideo() async {
    final XFile? pickedFile =
    await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_videoFile == null || _thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both video and thumbnail.')),
      );
      return;
    }

    setState(() {
      _isUploading = true; // Show loading indicator
    });

    try {
      final videoStorageRef = FirebaseStorage.instance
          .ref()
          .child('videos/${DateTime.now().millisecondsSinceEpoch}');
      final uploadVideoTask = videoStorageRef.putFile(_videoFile!);
      final videoSnapshot = await uploadVideoTask.whenComplete(() => {});
      final videoDownloadUrl = await videoSnapshot.ref.getDownloadURL();

      final thumbnailStorageRef = FirebaseStorage.instance
          .ref()
          .child('thumbnails/${DateTime.now().millisecondsSinceEpoch}');
      final uploadThumbnailTask = thumbnailStorageRef.putFile(_thumbnailFile!);
      final thumbnailSnapshot = await uploadThumbnailTask.whenComplete(() => {});
      final thumbnailDownloadUrl = await thumbnailSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('videos').add({
        'url': videoDownloadUrl,
        'thumbnailUrl': thumbnailDownloadUrl,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'userId': widget.user.uid,
        'userName': widget.user.displayName ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
        'viewCount': 0,
      });

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _videoFile = null;
        _thumbnailFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video is successfully uploaded.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading video: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    ); // Redirect to SelectRolePage
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Upload Video', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.black],
              ),
            ),
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
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
                      Center(
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickVideo,
                              icon: const Icon(Icons.video_library),
                              label: const Text('Select Video'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            if (_videoFile != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Selected Video: ${_videoFile!.path.split('/').last}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ElevatedButton.icon(
                              onPressed: _pickThumbnail,
                              icon: const Icon(Icons.image),
                              label: const Text('Select Thumbnail'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            if (_thumbnailFile != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Selected Thumbnail: ${_thumbnailFile!.path.split('/').last}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: _uploadVideo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          child: const Text('Upload Video',
                              style: TextStyle(fontSize: 16.0)),
                        ),

                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

