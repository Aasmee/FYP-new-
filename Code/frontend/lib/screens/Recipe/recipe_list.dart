import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.model.dart';
import 'package:frontend/screens/Recipe/recipe_tile.dart';
import 'package:frontend/services/recipe.service.dart';
import 'package:frontend/widgets/scan_icon.dart';

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
            final matchesQuery =
                recipe.name.toLowerCase().contains(query) ||
                recipe.tags.any((tag) => tag.toLowerCase().contains(query));
            final matchesTag =
                selectedTag.isEmpty ||
                recipe.tags
                    .map((e) => e.toLowerCase())
                    .contains(selectedTag.toLowerCase());
            return matchesQuery && matchesTag;
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
        actions: [IconButton(onPressed: () {}, icon: ScanFrameIcon())],
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
                  // Add your suggested action here
                  print("Suggested button clicked");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFAF7036),
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
