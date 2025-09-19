import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LibraryScreen extends StatefulWidget {
  final String schoolId;
  final String registrationNumber;
  final String classNumber;
  final String section;

  const LibraryScreen({
    Key? key,
    required this.schoolId,
    required this.registrationNumber,
    required this.classNumber,
    required this.section,
  }) : super(key: key);

  static String routeName = 'LibraryScreen';

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<List<Map<String, dynamic>>> _issuedBooksFuture;
  late String schoolId;
  late String registrationNumber;
  late String classNumber;
  late String section;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        schoolId = args?['schoolId'] ?? widget.schoolId;
        registrationNumber =
            args?['registrationNumber'] ?? widget.registrationNumber;
        classNumber = args?['class'] ?? widget.classNumber;
        section = args?['section'] ?? widget.section;
      });
      _issuedBooksFuture = fetchIssuedBooks();
    });
  }

  Future<List<Map<String, dynamic>>> fetchIssuedBooks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('library_management')
          .doc('student')
          .collection('class')
          .doc(classNumber)
          .collection(registrationNumber)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _issuedBooksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: _buildGradientBackground(
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: _buildGradientBackground(
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: _buildGradientBackground(
              child: const Center(
                child: Text(
                  'No Books Issued',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
          );
        } else {
          List<Map<String, dynamic>> issuedBooks = snapshot.data!;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: _buildGradientBackground(
              child: _buildIssuedBooksTable(issuedBooks),
            ),
          );
        }
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Books Issued',
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
    );
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  String formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('dd-MMM').format(date);
    }
    return 'N/A';
  }

  Widget _buildIssuedBooksTable(List<Map<String, dynamic>> issuedBooks) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
        },
        children: [
          // Table Header
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
            children: [
              _buildTableCell('Book Title', isHeader: true),
              _buildTableCell('Issued on', isHeader: true),
              _buildTableCell('Due Date', isHeader: true),
            ],
          ),
          // Table Rows
          ...issuedBooks.map((book) => TableRow(
                decoration: BoxDecoration(
                  color: issuedBooks.indexOf(book) % 2 == 0
                      ? Colors.white
                      : const Color(0xFFF9F9F9),
                ),
                children: [
                  _buildTableCell(book['bookTitle'] ?? 'N/A'),
                  _buildTableCell(formatDate(book['issuedDate'])),
                  _buildTableCell(formatDate(book['dueDate'])),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15.0,
          fontWeight: isHeader ? FontWeight.w500 : FontWeight.w400,
          color: isHeader ? Colors.black : Colors.grey[800],
        ),
      ),
    );
  }
}
