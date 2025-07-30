import 'package:flutter/material.dart';
import 'package:frontend/screens/Pantry/widgets/add_ingre.dart';
import 'package:frontend/screens/Pantry/widgets/item_topic.dart';
import 'package:frontend/widgets/button.dart';

class Pantry extends StatefulWidget {
  const Pantry({super.key, this.title});

  final String? title;

  @override
  PantryState createState() => PantryState();
}

class PantryState extends State<Pantry> {
  // Track active tab
  bool isIngredientsActive = true;

  // Controllers for the popup
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  void _toggleActiveTab(bool isIngredients) {
    setState(() {
      isIngredientsActive = isIngredients;
    });
  }

  void _showPopupBox() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AddIngredient(
          onClose: () => Navigator.of(context).pop(),
          nameController: nameController,
          quantityController: quantityController,
          expiryDateController: expiryDateController,
          categoryController: categoryController,
          unitController: unitController,
        );
      },
    );
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
                            children: const [
                              Items(),
                              Divider(),
                              Items(),
                              Divider(),
                              Items(),
                              Divider(),
                              Items(),
                              Divider(),
                              Items(),
                              Divider(),
                              Items(),
                            ],
                          ),
                        ),
                      ],
                    )
                    : ListView(
                      children: [
                        //   RecipeCard(
                        //       imagePath: 'images/Bossam.jpeg',
                        //       label: 'Bossam',
                        //       subtitle: 'You have all the ingredients')
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
