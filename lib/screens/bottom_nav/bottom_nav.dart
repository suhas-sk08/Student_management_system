import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student1/screens/academic_screen/academic.dart';
import 'package:student1/screens/chat_screen/chat_comingsoon.dart';
import 'package:student1/screens/chat_screen/teacherdisplay.dart';
import 'package:student1/screens/home_screen/home_screen.dart';
import 'package:student1/screens/my_profile/my_profile.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final String schoolId;
  final String phoneNumber;
  final String classNumber;
  final String registrationNumber;
  final String section;

  const BottomNavBar(
      {Key? key,
      required this.selectedIndex,
      required this.schoolId,
      required this.phoneNumber,
      required this.classNumber,
      required this.section,
      required this.registrationNumber})
      : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String studentName = '';

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
  }

  Future<void> _fetchStudentName() async {
    try {
      if (widget.schoolId.isEmpty || widget.phoneNumber.isEmpty) {
        throw Exception('School ID and phone number must not be empty');
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(widget.schoolId)
          .doc(widget.schoolId)
          .collection('students')
          .doc('class')
          .collection(widget.classNumber)
          .where('phoneNumber', isEqualTo: widget.phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs.first;
        setState(() {
          studentName = documentSnapshot.data()['studentName'] ?? 'Student';
        });
      } else {
        setState(() {
          studentName = 'Student';
        });
      }
    } catch (e) {
      setState(() {
        studentName = 'Student';
      });
      print('Failed to fetch student name: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == widget.selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushNamed(context, HomeScreen.routeName);
        break;
      case 1:
        Navigator.pushNamed(
          context,
          ChatComingSoon.routeName,
          arguments: {
            'schoolId': widget.schoolId,
            'phoneNumber': widget.phoneNumber,
            'studentName': studentName,
            'class': widget.classNumber,
            'section': widget.section,
          },
        );
        break;
      case 2:
        Navigator.pushNamed(
          context,
          AcademicScreen.routeName,
          arguments: {
            'schoolId': widget.schoolId,
            'phoneNumber': widget.phoneNumber,
            'studentName': studentName,
            'class': widget.classNumber,
            'section': widget.section,
          },
        );
        break;
      case 3:
        Navigator.pushNamed(
          context,
          MyProfileScreen.routeName,
          arguments: {
            'schoolId': widget.schoolId,
            'phoneNumber': widget.phoneNumber,
            'studentName': studentName,
            'class': widget.classNumber,
            'section': widget.section,
            'registrationNumber': widget.registrationNumber,
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // Background color of navbar
        borderRadius: BorderRadius.circular(0),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: widget.selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false, // Hide default labels
        showUnselectedLabels: false, // Hide labels for unselected items
        elevation: 0,
        items: [
          _buildNavItem(0, 'assets/icon/home_icon.svg', 'Home'),
          _buildNavItem(1, 'assets/icon/chat_icon.svg', 'Chat'),
          _buildNavItem(2, 'assets/icon/calendar_month.svg', 'Events'),
          _buildNavItem(3, 'assets/icon/user_icon.svg', 'Profile'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      int index, String iconPath, String label) {
    bool isSelected = index == widget.selectedIndex;

    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: Color(0xFFFE516D), // Background for selected item
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 20,
              color: isSelected
                  ? Colors.white
                  : Colors.black, // White for selected, grey for unselected
            ),
            if (isSelected) SizedBox(width: 3), // Space between icon and text
            if (isSelected)
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white, // Text color for selected item
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
      label: '', // Hide default label
    );
  }
}
