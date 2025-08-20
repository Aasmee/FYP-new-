import 'package:flutter/material.dart';
import 'package:new_frontend/screens/Pantry/widgets/add_ingre.dart';
import 'package:new_frontend/services/pantry.service.dart';
import 'package:new_frontend/widgets/button.dart';

class Pantry extends StatefulWidget {
  const Pantry({super.key, this.title});

  final String? title;

  @override
  PantryState createState() => PantryState();
}

class PantryState extends State<Pantry> {
  bool isIngredientsActive = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  List<dynamic> pantryItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPantry();
  }

  Future<void> fetchPantry() async {
    try {
      final items = await PantryService.getPantryItems();
      setState(() {
        pantryItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading pantry items: $e')));
    }
  }

  void _toggleActiveTab(bool isIngredients) {
    setState(() {
      isIngredientsActive = isIngredients;
    });
  }

  void _showPopupBox() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AddIngredient(
          onClose: () => Navigator.of(context).pop(false),
          nameController: nameController,
          quantityController: quantityController,
          expiryDateController: expiryDateController,
          categoryController: categoryController,
          unitController: unitController,
        );
      },
    );

    if (result == true) {
      fetchPantry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My Pantry',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Button(
                    text: 'Ingredients',
                    onPressed: () => _toggleActiveTab(true),
                    color:
                        isIngredientsActive
                            ? const Color(0xFFAF7036)
                            : const Color(0xFFD4B293),
                    txtColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Button(
                    text: 'Recipes',
                    onPressed: () => _toggleActiveTab(false),
                    color:
                        isIngredientsActive
                            ? const Color(0xFFD4B293)
                            : const Color(0xFFAF7036),
                    txtColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                isIngredientsActive
                    ? ListView(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children:
                                isLoading
                                    ? [
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ]
                                    : pantryItems.map((item) {
                                      return ListTile(
                                        title: Text(item['name']),
                                        subtitle: Text(
                                          '${item['quantity']} ${item['unit']}',
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            await PantryService.deletePantryItem(
                                              item['id'],
                                            );
                                            fetchPantry();
                                          },
                                        ),
                                      );
                                    }).toList(),
                          ),
                        ),
                      ],
                    )
                    : ListView(
                      children: const [
                        // Add recipe widgets here later
                      ],
                    ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
            child: Button(
              text: 'Add Ingredients',
              onPressed: _showPopupBox,
              color: const Color(0xFFAF7036),
              txtColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
