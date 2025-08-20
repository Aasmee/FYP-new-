import 'package:flutter/material.dart';
import 'package:new_frontend/models/recipe.model.dart';
import 'package:new_frontend/screens/Recipe/recipe_tile.dart';
import 'package:new_frontend/services/recipe.service.dart';

class SuggestedRecipesScreen extends StatefulWidget {
  const SuggestedRecipesScreen({super.key});

  @override
  State<SuggestedRecipesScreen> createState() => _SuggestedRecipesScreenState();
}

class _SuggestedRecipesScreenState extends State<SuggestedRecipesScreen> {
  List<Recipe> suggestedRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestedRecipes();
  }

  Future<void> _fetchSuggestedRecipes() async {
    try {
      final recipes = await RecipeService.fetchRecommendedRecipes();
      setState(() {
        suggestedRecipes = recipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load suggested recipes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suggested Recipes"),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : suggestedRecipes.isEmpty
              ? const Center(
                child: Text(
                  "No suggestions available",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
              : ListView.builder(
                itemCount: suggestedRecipes.length,
                itemBuilder:
                    (_, index) => RecipeTile(
                      recipe: suggestedRecipes[index],
                      onTagSelected: (tag) {
                        // Optional: handle tag clicks inside suggestions page
                      },
                      selectedTag: "",
                    ),
              ),
    );
  }
}
