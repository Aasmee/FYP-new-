import 'dart:convert';
import 'package:frontend/models/recipe.model.dart';
import 'package:http/http.dart' as http;

class RecipeService {
  static const baseUrl = "http://localhost:3001/recipes";

  static Future<List<Recipe>> fetchRecipes() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Recipe.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch recipes");
    }
  }

  static Future<Recipe> fetchRecipeById(String id) async {
    final res = await http.get(Uri.parse("$baseUrl/$id"));
    if (res.statusCode == 200) {
      return Recipe.fromJson(json.decode(res.body));
    } else {
      throw Exception("Failed to fetch recipe");
    }
  }
}
