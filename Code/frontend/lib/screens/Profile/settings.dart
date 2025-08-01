import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FilledButton(
              onPressed: () {
                // Navigate to Edit Profile page
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFAF7036),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("Edit Profile"),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/login");
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFAF7036),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }
}
