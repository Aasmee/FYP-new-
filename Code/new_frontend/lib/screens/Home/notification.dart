// screens/Notifications/notification_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_frontend/constants.dart';
import 'package:new_frontend/models/notifications.model.dart';
import 'package:new_frontend/services/authServices.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        setState(() {
          notifications =
              jsonData.map((data) => NotificationModel.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch notifications';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final token = await AuthService.getToken();
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
    setState(() {
      notifications =
          notifications.map((n) {
            if (n.id == notificationId) {
              return NotificationModel(
                id: n.id,
                type: n.type,
                message: n.message,
                postImage: n.postImage,
                read: true,
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
              ? Center(child: Text(error))
              : notifications.isEmpty
              ? const Center(child: Text("No notifications"))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return ListTile(
                    tileColor: notif.read ? Colors.grey[200] : Colors.white,
                    leading:
                        notif.postImage != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                notif.postImage!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Icon(Icons.notifications),
                    title: Text(notif.message),
                    subtitle: Text(
                      notif.createdAt.toLocal().toString().split('.')[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => markAsRead(notif.id),
                  );
                },
              ),
    );
  }
}
