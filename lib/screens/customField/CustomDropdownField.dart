import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.selectedValue,
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
        const SizedBox(height: 3), // Space between label and dropdown
        SizedBox(
          height: 60, // Set fixed height for dropdown
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0x66F1F5F9),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            hint: Text(
              "Select $label",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.67,
                          letterSpacing: 0.20,
                        ),
                      ),
                    ))
                .toList(),
            validator: validator,
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
            ),
            dropdownColor: Colors.white,
            menuMaxHeight: 200,
          ),
        ),
      ],
    );
  }
}
