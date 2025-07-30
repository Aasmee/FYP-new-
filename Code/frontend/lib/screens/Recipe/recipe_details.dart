import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.model.dart';
import 'package:frontend/services/recipe.service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;
  final Function(String) onTagSelected;
  final String selectedTag;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeId,
    required this.onTagSelected,
    required this.selectedTag,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late Future<Recipe> futureRecipe;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    futureRecipe = RecipeService.fetchRecipeById(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });
            },
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
          ),
        ],
      ),
      body: FutureBuilder<Recipe>(
        future: futureRecipe,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load recipe"));
          } else {
            final recipe = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      recipe.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 5,
                    children:
                        recipe.tags.take(3).map((tag) {
                          final isSelected = tag == widget.selectedTag;
                          return ActionChip(
                            label: Text(
                              tag,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            backgroundColor:
                                isSelected
                                    ? const Color(0xFFAF7036)
                                    : Colors.white,
                            onPressed: () => widget.onTagSelected(tag),
                            pressElevation: 4,
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Ingredients",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...recipe.ingredients.map((ing) => Text("- $ing")),
                  const SizedBox(height: 16),
                  const Text(
                    "Steps",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...recipe.steps.map(
                    (s) => Text("${s['order']}. ${s['content']}"),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
