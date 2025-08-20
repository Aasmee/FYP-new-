import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class TextScannerScreen extends StatefulWidget {
  final Function(String) onTextExtracted;
  const TextScannerScreen({super.key, required this.onTextExtracted});

  @override
  State<TextScannerScreen> createState() => _TextScannerScreenState();
}

class _TextScannerScreenState extends State<TextScannerScreen> {
  File? _image;
  final picker = ImagePicker();
  String _scannedText = '';
  late final TextRecognizer _textRecognizer;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  @override
  void dispose() {
    _textRecognizer.close(); // Dispose to free native resources
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      await _scanText(File(pickedFile.path));
    }
  }

  Future<void> _scanText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      String extractedText = recognizedText.text;
      setState(() => _scannedText = extractedText);

      widget.onTextExtracted(extractedText);
    } catch (e, st) {
      debugPrint('Error scanning text: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to recognize text: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Text")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Capture Image"),
          ),
          const SizedBox(height: 20),
          if (_image != null) Image.file(_image!, height: 200),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _scannedText.isEmpty ? "No text scanned yet." : _scannedText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
