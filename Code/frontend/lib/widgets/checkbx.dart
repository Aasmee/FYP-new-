import 'package:flutter/material.dart';

class Checkbx extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  const Checkbx({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, checkColor: Colors.white),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
