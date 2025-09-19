import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDisplayField extends StatelessWidget {
  final String label;
  final String? value; // Now stores the value to display instead of editing

  const CustomDisplayField({
    Key? key,
    required this.label,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.67,
            letterSpacing: 0.20,
          ),
        ),
        const SizedBox(height: 3),
        Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              color:
                  Color(0x66F1F5F9), // Light grey background for read-only feel
            ),
            alignment: Alignment.centerLeft,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? '--', // Show '--' if value is null
                    style: GoogleFonts.poppins(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                      letterSpacing: 0.20,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icon/lock_icon.svg',
                    width: 50,
                    height: 22,
                  ),
                ])),
      ],
    );
  }
}
