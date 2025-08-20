import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_frontend/models/recipe.model.dart';
import 'package:new_frontend/screens/Recipe/recipe_details.dart';

class RecipeTile extends StatelessWidget {
  final Recipe recipe;
  final Function(String) onTagSelected;
  final String selectedTag;

  const RecipeTile({
    super.key,
    required this.recipe,
    required this.onTagSelected,
    required this.selectedTag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => RecipeDetailsScreen(
                    recipeId: recipe.id,
                    onTagSelected: (String tag) {
                      // Handle tag selection inside RecipeDetailsScreen if needed
                      // For example, print or update some state
                      if (kDebugMode) {
                        print('Tag selected in details screen: $tag');
                      }
                    },
                    selectedTag: '',
                  ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe.imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 5,
                        children:
                            recipe.tags.take(3).map((tag) {
                              final isSelected = tag == selectedTag;
                              return ActionChip(
                                label: Text(
                                  tag,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                backgroundColor:
                                    isSelected
                                        ? const Color(0xFFAF7036)
                                        : Colors.white,
                                onPressed: () => onTagSelected(tag),
                                pressElevation: 4,
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.bookmark_border),
            ],
          ),
        ),
      ),
    );
  }
}
