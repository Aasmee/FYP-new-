import 'package:flutter/material.dart';
import 'package:new_frontend/services/pantry.service.dart';
import 'package:new_frontend/widgets/button.dart';
import 'package:new_frontend/widgets/dropdownbtn.dart';
import 'package:new_frontend/widgets/txtfield.dart';

class AddIngredient extends StatefulWidget {
  final VoidCallback onClose;
  final TextEditingController nameController;
  final TextEditingController expiryDateController;
  final TextEditingController categoryController;
  final TextEditingController quantityController;
  final TextEditingController unitController;

  const AddIngredient({
    super.key,
    required this.onClose,
    required this.nameController,
    required this.expiryDateController,
    required this.categoryController,
    required this.quantityController,
    required this.unitController,
  });

  @override
  AddIngredientState createState() => AddIngredientState();
}

class AddIngredientState extends State<AddIngredient> {
  String? selectedCategory;
  String? selectedUnit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingredient Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Textfield(
                controller: widget.nameController,
                label: 'Ingredient Name',
                labelColor: Colors.black,
                hintText: 'Name',
                hintColor: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Textfield(
                controller: widget.expiryDateController,
                label: 'Expiry Date',
                labelColor: Colors.black,
                hintText: 'YYYY/MM/DD',
                hintColor: Colors.grey[400],
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Dropdownbtn<String>(
                label: 'Category',
                items: ['Vegetable', 'Fruit', 'Dairy', 'Meat', 'Grain'],
                onChanged: (String? value) {
                  setState(() {
                    selectedCategory = value;
                    widget.categoryController.text = value ?? '';
                  });
                },
                hintText: 'Select a Category',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Textfield(
                    controller: widget.quantityController,
                    label: 'Quantity',
                    labelColor: Colors.black,
                    hintText: 'Quantity',
                    hintColor: Colors.grey[400],
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Dropdownbtn<String>(
                    label: 'Unit',
                    items: ['kg', 'g', 'L', 'mL', 'pcs'],
                    onChanged: (String? value) {
                      setState(() {
                        selectedUnit = value;
                        widget.unitController.text = value ?? '';
                      });
                    },
                    hintText: 'Select a Unit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Button(
              text: 'Add',
              color: const Color(0xFFAF7036),
              txtColor: Colors.white,
              onPressed: () async {
                if (widget.nameController.text.isNotEmpty &&
                    widget.quantityController.text.isNotEmpty &&
                    widget.unitController.text.isNotEmpty) {
                  final newItem = {
                    "name": widget.nameController.text,
                    "quantity": widget.quantityController.text,
                    "unit": widget.unitController.text,
                    "category": widget.categoryController.text,
                  };

                  await PantryService.addPantryItem(newItem);
                  Navigator.pop(context, true); // send signal to refresh
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
