// lib/screens/profile.dart
import 'package:flutter/material.dart';
import 'package:frontend/services/profileServices.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({super.key, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> userPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final profile = await _profileService.fetchUserProfile(widget.token);
    if (profile != null) {
      setState(() {
        userData = profile;
      });
      final posts = await _profileService.fetchUserPosts(
        widget.token,
        profile['id'],
      );
      setState(() {
        userPosts = posts;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load user data")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile info
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    userData!['profilePicture'] ??
                        'https://via.placeholder.com/150',
                  ), // fallback placeholder
                ),
                const SizedBox(width: 16),
                Text(
                  userData!['username'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Posts
            Expanded(
              child:
                  userPosts.isEmpty
                      ? const Center(child: Text("No posts yet"))
                      : ListView.builder(
                        itemCount: userPosts.length,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(post['caption'] ?? ''),
                              leading:
                                  post['imageUrls'] != null &&
                                          post['imageUrls'].isNotEmpty
                                      ? Image.network(
                                        post['imageUrls'][0],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                      : const Icon(Icons.image_not_supported),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
