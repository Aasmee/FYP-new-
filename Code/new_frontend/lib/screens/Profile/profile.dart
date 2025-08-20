import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:new_frontend/constants.dart';
import 'package:new_frontend/screens/Profile/post_detail.dart';
import 'package:new_frontend/screens/Profile/settings.dart';
import 'package:new_frontend/services/authServices.dart';

import '../../services/saved_posts_notifier.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showPosts = true;
  Map<String, dynamic>? profileData;
  static final String _baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('Profile data: $data');
      savedPostsNotifier.setPosts(
        List<Map<String, dynamic>>.from(data['savedPosts']),
      );
      setState(() {
        profileData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profileData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final posts = List<Map<String, dynamic>>.from(profileData!['posts']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Profile"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    profileData!['profileImage'] ??
                        'https://i.pravatar.cc/150?u=${profileData!['username']}',
                  ),
                ),
                Text(
                  profileData!['username'],
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Toggle buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleButton("Posts", showPosts, () {
                setState(() => showPosts = true);
              }),
              _buildToggleButton("Saved", !showPosts, () {
                setState(() => showPosts = false);
              }),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child:
                showPosts
                    ? _buildPostsGrid(posts)
                    : ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: savedPostsNotifier,
                      builder: (context, savedPosts, _) {
                        if (savedPosts.isEmpty) {
                          return const Center(child: Text("No saved posts"));
                        }
                        return _buildPostsGrid(savedPosts);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(List<Map<String, dynamic>> posts) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        final imagePaths = post['imagePaths'];

        if (imagePaths is List &&
            imagePaths.isNotEmpty &&
            imagePaths[0] != null) {
          final imageUrl = '$_baseUrl${imagePaths[0]}';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          );
        } else {
          if (kDebugMode) {
            print(
              'Skipping post at index $index because imagePaths is invalid: $imagePaths',
            );
          }
          return const SizedBox(); // Empty box if no image
        }
      },
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF9C5F2B) : Colors.brown[200],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
