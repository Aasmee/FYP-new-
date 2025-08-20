import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_frontend/constants.dart';
import 'package:new_frontend/models/recipe.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeService {
  /// Base URL for all recipe & recommendation endpoints
  static final String _recipesBase = "${ApiConfig.baseUrl}/recipes";
  static final String _recommendationsBase =
      "${ApiConfig.baseUrl}/recommendation";

  /// Fetch all recipes
  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse("$_recipesBase/"));
    print("Fetch Recipes Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Recipe.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch recipes");
    }
  }

  /// Fetch single recipe by id
  static Future<Recipe> fetchRecipeById(String id) async {
    final response = await http.get(Uri.parse("$_recipesBase/$id"));
    print("Fetch Recipe by ID Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to fetch recipe");
    }
  }

  /// Fetch recommended recipes for logged-in user
  static Future<List<Recipe>> fetchRecommendedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    print("Token being sent: $token");

    final response = await http.get(
      Uri.parse("$_recommendationsBase/tags"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Fetch Recommendations Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Recipe.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch recommended recipes');
    }
  }
}
