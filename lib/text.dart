
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncrementViewCountButton extends StatefulWidget {
  final String videoId; // Pass the video ID to identify the correct document

  const IncrementViewCountButton({super.key, required this.videoId});

  @override
  _IncrementViewCountButtonState createState() => _IncrementViewCountButtonState();
}

class _IncrementViewCountButtonState extends State<IncrementViewCountButton> {
  int _viewCount = 0; // Local state to show view count after increment

  // Function to increment the viewCount field in Firestore
  Future<void> incrementViewCount() async {
    try {
      // Get the document from Firestore by videoId
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('videos').doc(widget.videoId).get();

      // Check if the document exists
      if (doc.exists) {
        // Update the document by incrementing the viewCount field by 1
        await FirebaseFirestore.instance.collection('videos').doc(widget.videoId).update({
          'viewCount': FieldValue.increment(1),
        });

        // Retrieve the updated view count and update the state to display it locally
        DocumentSnapshot updatedDoc = await FirebaseFirestore.instance.collection('videos').doc(widget.videoId).get();
        setState(() {
          _viewCount = updatedDoc['viewCount'];
        });

        print('View count incremented successfully to $_viewCount.');
      } else {
        print('Document with videoId: ${widget.videoId} does not exist.');
      }
    } catch (e) {
      print('Error updating view count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await incrementViewCount();
      },
      child: Text('Increment View Count (Current: $_viewCount)'),
    );
  }
}




