import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color? hintColor;
  final String? label;
  final Color? labelColor;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const Textfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.hintColor,
    this.label,
    this.labelColor,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1, // Default to 1 line
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Color.fromRGBO(158, 158, 158, 0.3),
              width: 0.5,
            ),
            color: const Color.fromRGBO(255, 255, 255, 0.25),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: hintColor,
                fontStyle: FontStyle.normal,
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color.fromRGBO(255, 255, 255, 0.25),
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
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              prefixIcon:
                  prefixIcon != null
                      ? Icon(prefixIcon, color: Colors.grey[600])
                      : null,
              suffixIcon:
                  suffixIcon != null
                      ? GestureDetector(
                        onTap: onSuffixTap,
                        child: Icon(suffixIcon, color: Colors.grey[600]),
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
