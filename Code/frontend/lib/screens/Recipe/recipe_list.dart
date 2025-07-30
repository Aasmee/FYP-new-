import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.model.dart';
import 'package:frontend/screens/Recipe/recipe_tile.dart';
import 'package:frontend/services/recipe.service.dart';
import 'package:http/http.dart' as http;

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<List<Recipe>> futureRecipes;
  List<Recipe> allRecipes = [];
  List<Recipe> filteredRecipes = [];
  final TextEditingController searchController = TextEditingController();
  String selectedTag = "";

  @override
  void initState() {
    super.initState();
    futureRecipes = RecipeService.fetchRecipes();
    futureRecipes.then((recipes) {
      setState(() {
        allRecipes = recipes;
        filteredRecipes = recipes;
      });
    });
  }

  void _filterRecipes(String query) {
    final results =
        allRecipes
            .where(
              (recipe) =>
                  recipe.name.toLowerCase().contains(query.toLowerCase()) ||
                  recipe.tags.any(
                    (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                  ),
            )
            .toList();

    // Collect tags of filtered recipes
    final searchedTags = results.expand((r) => r.tags).toSet().toList();
    _sendSearchedTagsToBackend(searchedTags);

    setState(() {
      filteredRecipes = results;
      selectedTag = "";
    });
  }

  Future<void> _sendSearchedTagsToBackend(List<String> tags) async {
    final res = await http.post(
      Uri.parse('http://localhost:3001/recipes/save-tags'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tags": tags, "userId": "CURRENT_USER_ID"}),
    );
    if (res.statusCode != 200) {
      debugPrint("Failed to save searched tags: ${res.body}");
    }
  }

  void _filterByTag(String tag) {
    setState(() {
      selectedTag = tag;
      filteredRecipes =
          allRecipes
              .where(
                (recipe) => recipe.tags
                    .map((e) => e.toLowerCase())
                    .contains(tag.toLowerCase()),
              )
              .toList();
    });
  }

  void _clearFilter() {
    setState(() {
      selectedTag = "";
      searchController.clear();
      filteredRecipes = allRecipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Recipes",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterRecipes,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (selectedTag.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filtered by tag: $selectedTag",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _clearFilter,
                    icon: const Icon(Icons.clear),
                    label: const Text("Clear Filter"),
                  ),
                ],
              ),
            ),
          // --- Recipes List ---
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: futureRecipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Failed to load recipes"));
                } else {
                  return ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder:
                        (_, i) => RecipeTile(
                          recipe: filteredRecipes[i],
                          onTagSelected: _filterByTag,
                          selectedTag: selectedTag, // <-- added
                        ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
