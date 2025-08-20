import 'package:flutter/material.dart';

class Dropdownbtn<T> extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final List<T> items;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final Color? hintColor;

  const Dropdownbtn({
    super.key,
    required this.label,
    this.labelColor,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.hintText,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Color.fromRGBO(158, 158, 158, 0.3),
              width: 0.5,
            ),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<T>(
            dropdownColor: Colors.white,
            value: selectedValue,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: hintColor,
                fontStyle: FontStyle.normal,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: Color.fromRGBO(158, 158, 158, 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: Color.fromRGBO(158, 158, 158, 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.blue, width: 1),
              ),
            ),
            isExpanded: true,
            items:
                items.map((T value) {
                  return DropdownMenuItem<T>(
                    value: value,
                    child: Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
