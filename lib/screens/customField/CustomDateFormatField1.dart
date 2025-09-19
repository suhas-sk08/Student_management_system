import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomDateFormatField1 extends StatefulWidget {
  final String label;
  final ValueChanged<DateTime?> onComplete;
  final TextEditingController controller;

  const CustomDateFormatField1({
    Key? key,
    required this.label,
    required this.onComplete,
    required this.controller,
    required String hintText,
    required String? Function(dynamic value) validator,
  }) : super(key: key);

  @override
  _CustomDateFormatField1State createState() => _CustomDateFormatField1State();
}

class _CustomDateFormatField1State extends State<CustomDateFormatField1> {
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2150),
    );

    if (selectedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

      setState(() {
        widget.controller.text = formattedDate; // Ensure valid format
      });

      widget.onComplete(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 60,
          child: TextFormField(
            controller: widget.controller,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0x66F1F5F9),
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
              hintText: "Select a date",
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            ),
          ),
        )
      ],
    );
  }
}
