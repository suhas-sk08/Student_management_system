import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student1/screens/bottom_nav/bottom_nav.dart';

class ChatComingSoon extends StatefulWidget {
  final String schoolId;
  final String phoneNumber;
  final String classNumber;
  final String section;
  final String registrationNumber;
  final String studentName;

  const ChatComingSoon({
    Key? key,
    required this.schoolId,
    required this.phoneNumber,
    required this.classNumber,
    required this.section,
    required this.studentName,
    required this.registrationNumber,
  }) : super(key: key);

  static String routeName = 'ChatComingSoon';

  @override
  _ChatComingSoonState createState() => _ChatComingSoonState();
}

class _ChatComingSoonState extends State<ChatComingSoon> {
  late String schoolId;
  late String phoneNumber;
  String? classNumber;
  String? registrationNumber;
  String? studentName;
  String? section;

  TextEditingController textarea = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Ensure arguments are retrieved AFTER the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      setState(() {
        schoolId = args?['schoolId'] ?? widget.schoolId;
        studentName = args?['studentName'] ?? widget.studentName;
        phoneNumber = args?['phoneNumber'] ?? widget.phoneNumber;
        classNumber = args?['class'] ?? widget.classNumber;
        section = args?['section'] ?? widget.section;
        registrationNumber =
            args?['registrationNumber'] ?? widget.registrationNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String schoolId = args['schoolId'];
    final String phoneNumber = args['phoneNumber'];
    final String classNumber = args['class'] ?? '';
    final String section = args['section'] ?? '';
    final String studentName = args['studentName'] ?? '';
    final String registrationNumber = args['registratioNumber'] ?? '';

    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        schoolId: schoolId,
        phoneNumber: phoneNumber,
        classNumber: classNumber,
        section: section,
        registrationNumber: registrationNumber,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                'Chat',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.41,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
            ),
            Expanded(
                child: Center(
              child: Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
