import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static final String _baseUrl = "${ApiConfig.baseUrl}/post";
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<File> _images = [];
  File? _video;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      setState(() {
        _images = pickedFile.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      setState(() {
        _video = File(pickedVideo.path);
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _createPost() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    setState(() => _isLoading = true);

    var uri = Uri.parse('$_baseUrl/create');
    var request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['title'] = _titleController.text
          ..fields['description'] = _descController.text;

    for (var img in _images) {
      final mimeType = lookupMimeType(img.path);
      final mediaType =
          mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('image', 'jpeg');
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          img.path,
          contentType: mediaType,
        ),
      );
    }

    if (_video != null) {
      final videoMimeType = lookupMimeType(_video!.path);
      final videoMediaType =
          videoMimeType != null
              ? MediaType.parse(videoMimeType)
              : MediaType('video', 'mp4');
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          _video!.path,
          contentType: videoMediaType,
        ),
      );
    }

    var response = await request.send();
    final responseData = await http.Response.fromStream(response);

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavBar()),
        (route) => false,
      );
    } else {
      if (kDebugMode) {
        print('Backend response: ${responseData.body}');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Create New Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAF7036),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isLoading ? null : _createPost,
            child: const Text(
              "POST",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: "Description"),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children:
                    _images
                        .map(
                          (e) => Image.file(
                            e,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                        .toList(),
              ),
              if (_video != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Video Selected: ${_video!.path.split('/').last}',
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam),
                    onPressed: _pickVideo,
                  ),
                ],
              ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
