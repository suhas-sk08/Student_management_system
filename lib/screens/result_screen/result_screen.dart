import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultScreen extends StatefulWidget {
  final String schoolId;
  final String registrationNumber;
  final String classNumber;
  final String section;

  const ResultScreen({
    Key? key,
    required this.schoolId,
    required this.registrationNumber,
    required this.classNumber,
    required this.section,
  }) : super(key: key);

  static String routeName = 'ResultScreen';

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<List<String>> _examTypesFuture;
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
      if (args != null) {
        setState(() {
          schoolId = args['schoolId'] ?? widget.schoolId;
          registrationNumber =
              args['registrationNumber'] ?? widget.registrationNumber;
          classNumber = args['class'] ?? widget.classNumber;
          section = args['section'] ?? widget.section;
        });
      } else {
        setState(() {
          schoolId = widget.schoolId;
          registrationNumber = widget.registrationNumber;
          classNumber = widget.classNumber;
          section = widget.section;
        });
      }
      print(
          'Initialized with schoolId: $schoolId, registrationNumber: $registrationNumber, classNumber: $classNumber, section: $section');
      _examTypesFuture = fetchExamTypes();
    });
  }

  Future<List<String>> fetchExamTypes() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('exams')
          .doc('class')
          .collection(classNumber)
          .doc('section')
          .collection(section)
          .get();
      return snapshot.docs
          .map((doc) => doc['examType'] as String? ?? '')
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchExamTypes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
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
            body: _buildGradientBackground(
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // **No exam types available → Show "No Results Available"**
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Result',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.41,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: Colors.black, // Back icon color
              ),
            ),
            body: _buildGradientBackground(
              child: const Center(
                child: Text(
                  'No Results available',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
          );
        } else {
          List<String> examTypes = snapshot.data!;

          return DefaultTabController(
            length: examTypes.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Result',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.41,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(
                  color: Colors.black,
                ),
                bottom: TabBar(
                  isScrollable: true,
                  labelColor: const Color(0xFFEE8010),
                  unselectedLabelColor: Colors.black87,
                  labelStyle: GoogleFonts.poppins(
                    color: const Color(0xFF333333),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  indicatorColor: const Color(0xFFEE8010),
                  tabs: examTypes.map((name) => Tab(text: name)).toList(),
                ),
              ),
              body: _buildGradientBackground(
                child: TabBarView(
                  children: examTypes.map((name) {
                    return _buildResultTable(context, name);
                  }).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // Dark Blue at the top
            Color(0xFFFFFFFF), // Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  Widget _buildResultTable(BuildContext context, String examType) {
    if (examType.isEmpty) {
      return Center(
        child: Text(
          'No results available',
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('results')
          .doc('class')
          .collection(classNumber)
          .doc('section')
          .collection(section)
          .doc(examType)
          .collection('students')
          .doc(registrationNumber)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              'No results available',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        } else {
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final subjects = data['subjects'] as Map<String, dynamic>? ?? {};

          if (subjects.isEmpty) {
            return Center(
              child: Text(
                'No results available',
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          double totalObtainedMarks = 0;
          double totalMarks = 0;

          for (var entry in subjects.entries) {
            totalObtainedMarks +=
                _convertToDouble(entry.value['obtained_marks']);
            totalMarks += _convertToDouble(entry.value['total_marks']);
          }

          String overallGrade =
              calculateOverallGrade(totalObtainedMarks, totalMarks);

          return Container(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(20),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(5.6),
                      1: FlexColumnWidth(6),
                      2: FlexColumnWidth(5),
                      3: FlexColumnWidth(4.3),
                    },
                    defaultColumnWidth: const FixedColumnWidth(100.0),
                    border: TableBorder.all(
                      color: Colors.transparent,
                      style: BorderStyle.solid,
                      width: 0,
                    ),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Color(0xFFF9F9F9),
                        ),
                        children: [
                          for (var header in [
                            'Subject',
                            'Scored',
                            'Total',
                            "Grade"
                          ])
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  header,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      for (var entry
                          in subjects.entries.toList().asMap().entries)
                        TableRow(
                          decoration: BoxDecoration(
                            color: entry.key.isEven
                                ? Colors.white
                                : const Color(0xFFF9F9F9),
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  entry.value.key,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF053D80),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  entry.value.value['obtained_marks']
                                          ?.toString() ??
                                      'N/A',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  entry.value.value['total_marks']
                                          ?.toString() ??
                                      'N/A',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  calculateGrade(
                                    _convertToDouble(
                                        entry.value.value['obtained_marks']),
                                    _convertToDouble(
                                        entry.value.value['total_marks']),
                                  ),
                                  style: GoogleFonts.poppins(
                                      fontSize: 15.0,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }

  double _convertToDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  String calculateOverallGrade(double obtainedMarks, double totalMarks) {
    if (totalMarks == 0) return 'N/A';
    double percentage = (obtainedMarks / totalMarks) * 100;
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  String calculateGrade(double obtainedMarks, double totalMarks) {
    if (totalMarks == 0) return 'N/A';
    double percentage = (obtainedMarks / totalMarks) * 100;
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }
}
