import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDescriptionField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;

  const CustomDescriptionField({
    Key? key,
    required this.label,
    this.controller,
    this.hintText,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null, // Allows it to expand dynamically
          minLines: 3, // Ensures at least 3 empty lines in the field
          textInputAction: TextInputAction.newline, // Enter goes to next line
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0x66F1F5F9), // Light background
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 15), // More padding for better UI
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            hintText: hintText ?? 'Enter description...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
