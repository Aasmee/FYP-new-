import 'package:flutter/material.dart';
import 'package:new_frontend/services/listServices.dart';
import 'package:new_frontend/widgets/addpop.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, this.title});

  final String? title;

  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  // Controllers for popup fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  List<dynamic> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);
    try {
      final data = await fetchListItems();
      setState(() {
        items = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching items: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopupBox(
          onClose: () => Navigator.of(context).pop(),
          nameController: nameController,
          quantityController: quantityController,
          unitController: unitController,
        );
      },
    ).then((_) async {
      // Reload list after adding item
      await loadItems();
    });
  }

  Future<void> toggleCheckbox(int id, bool? value, int index) async {
    final success = await updateListItem(id, isChecked: value);
    if (success) {
      setState(() {
        items[index]['isChecked'] = value;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update item')));
    }
  }

  Future<void> deleteItem(int id, int index) async {
    final success = await deleteListItem(id);
    if (success) {
      setState(() {
        items.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete item')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shopping List',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          InkWell(
            onTap: _showPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.5),
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.black, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add to list',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? const Center(child: Text('No items yet'))
                    : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          leading: Checkbox(
                            value: item['isChecked'] ?? false,
                            onChanged:
                                (value) =>
                                    toggleCheckbox(item['id'], value, index),
                          ),
                          title: Text(
                            '${item['name']} (${item['quantity']} ${item['unit']})',
                            style: TextStyle(
                              decoration:
                                  (item['isChecked'] ?? false)
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => deleteItem(item['id'] as int, index),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
