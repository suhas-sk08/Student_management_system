import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final TextEditingController? controller;
  final String? hintText;
  final bool isPassword;
  final VoidCallback? onHelpPressed;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    Key? key,
    required this.label,
    this.initialValue,
    this.controller,
    this.hintText,
    this.isPassword = false,
    this.onHelpPressed,
    this.validator,
    required Null Function(dynamic value) onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF6C7278),
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
            controller: controller ?? TextEditingController(text: initialValue),
            obscureText: isPassword,
            validator: validator,
            inputFormatters: [
              UpperCaseTextFormatter(), // Converts input to uppercase
            ],
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
                color: const Color(0xFF1A1C1E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.40,
                letterSpacing: -0.14,
              ),
              suffixIcon: onHelpPressed != null
                  ? IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.grey),
                      onPressed: onHelpPressed,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Input Formatter to Convert Text to Uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(), // Convert to uppercase
      selection: newValue.selection,
    );
  }
}
