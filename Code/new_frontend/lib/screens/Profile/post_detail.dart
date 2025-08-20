import 'package:flutter/material.dart';
import 'package:new_frontend/screens/Home/widgets/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full post view
          Center(
            child: Positioned.fill(
              child: SingleChildScrollView(child: PostWidget(post: post)),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
