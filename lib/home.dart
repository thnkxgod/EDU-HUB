import 'package:EduHub/subcriptionTab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'videoTile.dart';
import 'channel_page.dart';
import 'homeTab.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize pages with VideosList for Home and SubscriptionTab for Subscriptions
    _pages.addAll([
      VideosList(key: _homeListKey, isSubscriptionTab: false), // Home Tab
      const SubscriptionTab(), // Subscription Tab
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
              label: 'Trending',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.subscriptions),
              label: 'Favourite',
            ),
          ],
        ),
      ),
    );
  }
}





