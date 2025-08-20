import 'package:flutter/material.dart';
import 'package:new_frontend/models/recipe.model.dart';
import 'package:new_frontend/screens/Recipe/recipe_tile.dart';
import 'package:new_frontend/screens/Recipe/scanner_screen.dart';
import 'package:new_frontend/screens/Recipe/suggestion_screen.dart';
import 'package:new_frontend/services/recipe.service.dart';
import 'package:new_frontend/widgets/scan_icon.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<Recipe> allRecipes = [];
  List<Recipe> filteredRecipes = [];
  final TextEditingController searchController = TextEditingController();
  String selectedTag = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await RecipeService.fetchRecipes();
      setState(() {
        allRecipes = recipes;
        filteredRecipes = recipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredRecipes =
          allRecipes.where((recipe) {
            final matchesName = recipe.name.toLowerCase().contains(query);
            final matchesTag = recipe.tags.any(
              (tag) => tag.toLowerCase().contains(query),
            );
            final matchesIngredient = recipe.ingredients.any(
              (ing) => ing.toLowerCase().contains(query),
            );

            final matchesSelectedTag =
                selectedTag.isEmpty ||
                recipe.tags
                    .map((e) => e.toLowerCase())
                    .contains(selectedTag.toLowerCase());

            return (matchesName || matchesTag || matchesIngredient) &&
                matchesSelectedTag;
          }).toList();
    });
  }

  void _onTagSelected(String tag) {
    selectedTag = tag;
    _applyFilters();
  }

  void _clearFilter() {
    setState(() {
      selectedTag = "";
      searchController.clear();
    });
    _applyFilters();
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
        actions: [
          IconButton(
            icon: ScanFrameIcon(),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => TextScannerScreen(
                        onTextExtracted: (text) {
                          Navigator.pop(context, text);
                        },
                      ),
                ),
              );
              if (result != null && result is String) {
                searchController.text = result;
                _applyFilters(); // Reuse existing filter logic
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (_) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SuggestedRecipesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAF7036),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Suggested",
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: filteredRecipes.length,
                      itemBuilder:
                          (_, i) => RecipeTile(
                            recipe: filteredRecipes[i],
                            onTagSelected: _onTagSelected,
                            selectedTag: selectedTag,
                          ),
                    ),
          ),
        ],
      ),
    );
  }
}
