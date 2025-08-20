import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_frontend/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String _baseUrl = "${ApiConfig.baseUrl}/list";

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<List<dynamic>> fetchListItems() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('$_baseUrl/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch items');
  }
}

Future<bool> addListItem(String name, double quantity, String unit) async {
  final token = await getToken();
  final response = await http.post(
    Uri.parse('$_baseUrl/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'name': name, 'quantity': quantity, 'unit': unit}),
  );
  return response.statusCode == 201;
}

Future<bool> updateListItem(int id, {bool? isChecked}) async {
  final token = await getToken();
  final response = await http.patch(
    Uri.parse('$_baseUrl/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({if (isChecked != null) 'isChecked': isChecked}),
  );
  return response.statusCode == 200;
}

Future<bool> deleteListItem(int id) async {
  final token = await getToken();
  final response = await http.delete(
    Uri.parse('$_baseUrl/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  return response.statusCode == 200;
}
