// home.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/Home/list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isPressed = false;
  bool showNotificationContainer = false;
  bool showCommentContainer = false;
  bool isLoading = true;
  int? currentPostId; // Track which post's comments are being viewed

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        isLoading = true;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Consider showing an error message to the user
      debugPrint('Error fetching posts: $e');
    }
  }

  void _toggleNotificationContainer() {
    setState(() {
      isPressed = !isPressed;
      showNotificationContainer = !showNotificationContainer;
      if (showNotificationContainer) {
        // If showing notifications, hide comments
        showCommentContainer = false;
      }
    });
  }

  void _hideCommentContainer() {
    setState(() {
      showCommentContainer = false;
      currentPostId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Ingreedy",
          style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.list_alt, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ListPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    isPressed
                        ? Icons.notifications
                        : Icons.notifications_outlined,
                    color: Colors.black,
                  ),
                  onPressed: _toggleNotificationContainer,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchPosts,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text("Text"),
                  ),
                ),
              ),
          if (showNotificationContainer)
            Positioned(
              top: 0,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(20),
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      blurRadius: 4,
                      spreadRadius: -1,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'No notifications',
                    style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 12),
                  ),
                ),
              ),
            ),
          // if (showCommentContainer)
          //   Positioned(
          //     bottom: 0,
          //     left: 0,
          //     right: 0,
          //     child: CommentBox(
          //       onClose: _hideCommentContainer,
          //       postId: currentPostId,
          //     ),
          //   ),
        ],
      ),
    );
  }
}
