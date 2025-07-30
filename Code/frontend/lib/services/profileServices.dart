// lib/services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl = 'http://192.168.1.8:3001';

  Future<Map<String, dynamic>?> fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Failed to load user profile: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserPosts(
    String token,
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/post/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        print('❌ Failed to load user posts: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching posts: $e');
      return [];
    }
  }
}
