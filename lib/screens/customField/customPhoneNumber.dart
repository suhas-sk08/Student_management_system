import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class Customphonenumber extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final bool isPassword;
  final VoidCallback? onHelpPressed;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const Customphonenumber({
    Key? key,
    required this.label,
    this.controller,
    this.hintText,
    this.isPassword = false,
    this.onHelpPressed,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Color(0xFF6C7278),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.60,
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 60, // Fixed height for the text field container
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: validator,
            keyboardType: keyboardType, // Ensures numeric keyboard
            inputFormatters: inputFormatters, // Allows only numbers
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 27),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: Color(0xFF1A1C1E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.40,
                letterSpacing: -0.14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
