import 'package:flutter/material.dart';

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  ItemsState createState() => ItemsState();
}

class ItemsState extends State<Items> {
  bool _isExpanded = false; // Track expansion state

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded; // Toggle state
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.expand_less
                      : Icons.expand_more, // Change icon dynamically
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 10),
            const Text("- Flour"),
            const Text("- Sugar"),
            const Text("- Eggs"),
            // Add more items as needed
          ],
        ],
      ),
    );
  }
}
