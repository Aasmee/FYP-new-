// models/notification_model.dart
import 'package:frontend/constants.dart';

class NotificationModel {
  final int id;
  final String type;
  final String message;
  final String? postImage;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    this.postImage,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      postImage:
          (json['post']?['imagePaths'] as List?)?.isNotEmpty == true
              ? "${ApiConfig.baseUrl}/uploads/${json['post']['imagePaths'][0]}"
              : null,
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
