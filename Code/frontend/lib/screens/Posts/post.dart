import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  List<XFile> _mediaFiles = [];
  bool _commentsEnabled = true;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {
    final List<XFile>? pickedFiles =
        await _picker.pickMultiImage(); // For image only
    if (pickedFiles != null) {
      setState(() {
        _mediaFiles = pickedFiles;
      });
    }
  }

  Future<void> _submitPost() async {
    var uri = Uri.parse("http://<YOUR_BACKEND_IP>:<PORT>/api/posts");

    var request = http.MultipartRequest('POST', uri);
    request.fields['caption'] = _textController.text;
    request.fields['commentsEnabled'] = _commentsEnabled.toString();

    for (var file in _mediaFiles) {
      var mimeType = lookupMimeType(file.path)?.split('/');
      if (mimeType != null && mimeType.length == 2) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media',
            file.path,
            contentType: MediaType(mimeType[0], mimeType[1]),
          ),
        );
      }
    }

    // Send the request
    var response = await request.send();
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Post uploaded successfully!");
      }
    } else {
      if (kDebugMode) {
        print("Post upload failed: ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Button(
            text: "POST",
            color: Color(0xFFAF7036),
            txtColor: Colors.white,
            onPressed: _submitPost,
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/user.jpg'),
            ),
            title: TextField(
              controller: _textController,
              decoration: InputDecoration.collapsed(
                hintText: "What’s on your mind?",
              ),
            ),
          ),
          Wrap(
            children:
                _mediaFiles.map((file) {
                  return Image.file(
                    File(file.path),
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  );
                }).toList(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: Icon(Icons.camera_alt),
                label: Text("Photo/Video"),
              ),
              SwitchListTile(
                title: Text("Comments"),
                value: _commentsEnabled,
                onChanged: (val) {
                  setState(() => _commentsEnabled = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
