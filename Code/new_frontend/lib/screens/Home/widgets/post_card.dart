import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_frontend/constants.dart';
import 'package:new_frontend/services/authServices.dart';
import 'package:new_frontend/services/saved_posts_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  bool commented = false;
  late bool isBookmarked;
  List<dynamic> comments = [];
  bool isLoadingComments = false;
  final TextEditingController _commentController = TextEditingController();

  late PageController _pageController;
  int _currentPage = 0;
  int likeCount = 0;
  List<String> mediaPaths = [];
  static final String _baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    mediaPaths = List<String>.from(widget.post['imagePaths'] ?? []);
    likeCount = widget.post['likes'] ?? 0;
    isLiked = widget.post['isLiked'] ?? false;
    isBookmarked = widget.post['isBookmarked'] ?? false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void toggleLike(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Token not found");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/post/$postId/like',
        ), // Replace with your actual API URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
        print("Post liked/unliked successfully.");
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> fetchComments(int postId) async {
    setState(() => isLoadingComments = true);

    try {
      final response = await http.get(Uri.parse('$_baseUrl/comment/$postId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          comments = data['comments'];
        });
      } else {
        print("Failed to load comments: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching comments: $e");
    } finally {
      setState(() => isLoadingComments = false);
    }
  }

  void submitComment(int postId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      print("No token found");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/comment/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'text': text, 'postId': postId}),
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        // Refresh comments list after successful submit
        await fetchComments(postId);
      } else {
        print("Failed to post comment: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception posting comment: $e");
    }
  }

  Future<void> toggleBookmark() async {
    final token = await AuthService.getToken();
    final postId = widget.post['id'];

    final url = Uri.parse('$_baseUrl/bookmark/$postId');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = json.decode(response.body);
      final bookmarked = result['bookmarked'];

      setState(() {
        isBookmarked = bookmarked;
      });

      // Update global saved posts list
      if (bookmarked) {
        savedPostsNotifier.addPost(widget.post);
      } else {
        savedPostsNotifier.removePost(postId);
      }
    } else {
      debugPrint('Failed to toggle bookmark: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.post["user"] ?? {};
    final username = user["username"] ?? "Unknown User";
    String description = widget.post["description"];

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=$username',
              ),
            ),
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("1 day ago"),
            trailing: const Icon(Icons.more_vert),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(description),
          ),
          const SizedBox(height: 8),

          // Media Carousel (Only Images)
          if (mediaPaths.isNotEmpty)
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: mediaPaths.length,
                    onPageChanged:
                        (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final imageUrl = '$_baseUrl${mediaPaths[index]}';
                      return Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                if (mediaPaths.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        mediaPaths.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 10 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == index
                                    ? Colors.white
                                    : Colors.grey,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

          // Actions Row
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.black,
                ),
                onPressed: () => toggleLike(widget.post['id']),
              ),
              Text('$likeCount'),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  commented ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  color: Colors.black,
                ),
                onPressed: () async {
                  setState(() => commented = !commented);
                  if (!commented) {
                    return; // If closing comments, do nothing more
                  }
                  await fetchComments(widget.post['id']);
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.black,
                  ),
                  onPressed: toggleBookmark,
                ),
              ),
            ],
          ),
          if (commented)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  if (isLoadingComments)
                    const Center(child: CircularProgressIndicator()),
                  if (!isLoadingComments)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final username =
                            comment['user']['username'] ?? 'Unknown';
                        final text = comment['text'] ?? '';
                        return ListTile(
                          title: Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(text),
                        );
                      },
                    ),

                  // Input for adding new comment
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Add a comment...",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => submitComment(widget.post['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
