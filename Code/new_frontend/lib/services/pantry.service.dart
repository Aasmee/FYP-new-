import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_frontend/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantryService {
  static final String _baseUrl = "${ApiConfig.baseUrl}/pantry";

  static Future<List<dynamic>> getPantryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load pantry items");
    }
  }

  static Future<void> addPantryItem(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(item),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add pantry item");
    }
  }

  static Future<void> deletePantryItem(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete pantry item");
    }
  }
}
