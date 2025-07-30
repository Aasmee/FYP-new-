import 'package:flutter/material.dart';
import 'package:frontend/screens/Home/list.dart';
import 'package:frontend/services/listServices.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/dropdownbtn.dart';
import 'package:frontend/widgets/txtfield.dart';

class PopupBox extends StatefulWidget {
  final VoidCallback onClose;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;

  const PopupBox({
    super.key,
    required this.onClose,
    required this.nameController,
    required this.quantityController,
    required this.unitController,
  });

  @override
  PopupBoxState createState() => PopupBoxState();
}

class PopupBoxState extends State<PopupBox> {
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
                  'Add Item',
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
            Textfield(
              controller: widget.nameController,
              label: 'Name',
              labelColor: Colors.black,
              hintText: 'Item Name',
              hintColor: Colors.grey[400],
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
                    labelColor: Colors.black,
                    items: ['kg', 'g', 'L', 'mL', 'pcs', 'lbs', 'oz'],
                    onChanged: (String? value) {
                      setState(() {
                        selectedUnit = value;
                        widget.unitController.text = value ?? '';
                      });
                    },
                    hintText: 'Unit',
                    hintColor: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Button(
              text: 'Add',
              color: Color(0xFFAF7036),
              txtColor: Colors.white,
              onPressed: () async {
                if (widget.nameController.text.isNotEmpty &&
                    widget.quantityController.text.isNotEmpty &&
                    (selectedUnit?.isNotEmpty ?? false)) {
                  final success = await addListItem(
                    widget.nameController.text,
                    double.parse(widget.quantityController.text),
                    selectedUnit!,
                  );
                  if (success) {
                    Navigator.pop(context); // Close popup
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item added successfully')),
                    );
                    // Reload list
                    if (context.mounted) {
                      final parentState =
                          context.findAncestorStateOfType<ListPageState>();
                      parentState?.loadItems();
                    }
                  }
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
