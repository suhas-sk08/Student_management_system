import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:student1/constants.dart';
import 'widgets/assignment_widgets.dart';

class AssignmentScreen3 extends StatefulWidget {
  final String schoolId;
  final String phoneNumber;
  final String classNumber;
  final String section;

  const AssignmentScreen3({
    Key? key,
    required this.schoolId,
    required this.phoneNumber,
    required this.classNumber,
    required this.section,
  }) : super(key: key);

  static String routeName = 'AssignmentScreen3';

  @override
  _AssignmentScreen3State createState() => _AssignmentScreen3State();
}

class _AssignmentScreen3State extends State<AssignmentScreen3> {
  late String schoolId;
  late String phoneNumber;
  late String classNumber;
  late String section;
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        schoolId = args?['schoolId'] ?? widget.schoolId;
        phoneNumber = args?['phoneNumber'] ?? widget.phoneNumber;
        classNumber = args?['class'] ?? widget.classNumber;
        section = args?['section'] ?? widget.section;
      });
      _fetchAssignments(schoolId);
    });
  }

  void _showAssignmentDetails(
      BuildContext context, Map<String, dynamic> assignmentData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Assignment Details',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                      'Class : ${assignmentData['class'] ?? 'No Class'} ${assignmentData['section'] ?? 'No Section'}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  SizedBox(height: 10),
                  Text('Subject: ${assignmentData['subject'] ?? 'No Subject'}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 10),
                  Text('Teacher Name: ${assignmentData['teacherName'] ?? ''}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 10),
                  Text('Topic: ${assignmentData['topic'] ?? 'No topic'}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 10),
                  Text(
                      'Description: ${assignmentData['description'] ?? 'No Description'}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 10),
                  Text(
                      'Due Date: ${assignmentData['due_date'] != null ? DateFormat.yMMMd().format((assignmentData['due_date'] as Timestamp).toDate()) : 'No Due Date'}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchAssignments(String schoolId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      assignments = []; // Clear assignments before fetching
    });

    try {
      if (schoolId.isEmpty) {
        setState(() {
          errorMessage = "School ID not found";
          isLoading = false;
        });
        return;
      }

      Query query = FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('assignments')
          .doc('teacher')
          .collection('allAssignments')
          .where('class', isEqualTo: classNumber)
          .where('section', isEqualTo: section);

      // 🔹 Ensure Firestore allows ordering by 'due_date' (Check Firestore Indexing)
      query = query.orderBy('due_date', descending: true);

      QuerySnapshot assignmentsSnapshot = await query.get();

      List<Map<String, dynamic>> fetchedAssignments =
          assignmentsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; //  Store document ID for deletion
        return data;
      }).toList();

      debugPrint(
          "Debug: Total Fetched Assignments: ${fetchedAssignments.length}");

      setState(() {
        assignments = fetchedAssignments;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Debug: Error encountered: $e");
      setState(() {
        errorMessage = 'Error fetching assignments: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFFFFF), // Dark Blue at the top
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(children: [
              AppBar(
                title: Text(
                  'Assignments',
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
                  color: Colors.black, // Sets the back icon color to white
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignmentData =
                        assignments[index]; // Now directly a map
                    final id = assignmentData[
                        'id']; // Ensure this is stored in Firestore
                    final classes = assignmentData['class'] ?? 'No Class';
                    final section = assignmentData['section'] ?? 'No Section';
                    final subject = assignmentData['subject'] ?? 'No Subject';
                    final topic = assignmentData['topic'] ?? 'No topic';
                    final description =
                        assignmentData['description'] ?? 'No Description';
                    final teacherName = assignmentData['teacherName'] ?? '';
                    final dueDate = assignmentData['due_date'] != null
                        ? DateFormat('dd/MM/yyyy').format(
                            (assignmentData['due_date'] as Timestamp).toDate(),
                          )
                        : 'No Due Date';

                    return GestureDetector(
                      onTap: () =>
                          _showAssignmentDetails(context, assignmentData),
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: kDefaultPadding,
                          left: kDefaultPadding,
                          right: kDefaultPadding,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 159,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment(0.5, 0.8),
                                  colors: [
                                    Color(0xFFFAA248),
                                    Color(0xFFFDD6B5)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$classes $section',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    subject,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    topic,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    teacherName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 195,
                                    height: 1,
                                    child: const Divider(
                                      color: Colors.white,
                                      thickness: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Due on $dueDate',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ])));
  }
}
