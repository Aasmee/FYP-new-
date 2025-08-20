class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final List<String> ingredients;
  final List<Map<String, dynamic>> steps;

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.tags,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      ingredients: List<String>.from(json['ingredients']),
      steps: List<Map<String, dynamic>>.from(json['steps']),
    );
  }
}
