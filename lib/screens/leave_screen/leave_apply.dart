import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:student1/screens/customField/CustomDateFormatField1.dart';
import 'package:student1/screens/customField/CustomDropdownField.dart';
import 'package:student1/screens/customField/customDescriptionField.dart';

class LeaveScreen extends StatefulWidget {
  final String schoolId;
  final String studentName;
  final String phoneNumber;
  final String classNumber;
  final String section;
  const LeaveScreen({
    Key? key,
    required this.schoolId,
    required this.studentName,
    required this.phoneNumber,
    required this.classNumber,
    required this.section,
  }) : super(key: key);
  static String routeName = 'LeaveScreen';

  @override
  _LeaveScreenState createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? schoolId;
  String? phoneNumber;
  String? classNumber;
  String? section;
  List<String> leaveTypes = [
    'Sick',
    'Vacation',
    'Emergency',
    'Maternity',
    'Paternity',
    'Compensatory Off'
  ];
  String? studentName;
  String? _selectedLeaveType;
  DateTime selectedDate = DateTime.now();
  void _submitLeaveApplication() async {
    String fromDate = _fromDateController.text;
    String toDate = _toDateController.text;
    String reason = _reasonController.text;

    if (fromDate.isNotEmpty && toDate.isNotEmpty && reason.isNotEmpty) {
      try {
        // Convert the string date (dd-MM-yyyy) into a DateTime object
        DateTime parsedFromDate = DateFormat('dd-MM-yyyy').parse(fromDate);
        DateTime parsedToDate = DateFormat('dd-MM-yyyy').parse(toDate);

        // Format the dates to dd-MM-yyyy (optional, since it's already in this format)
        String formattedFromDate =
            DateFormat('dd-MM-yyyy').format(parsedFromDate);
        String formattedToDate = DateFormat('dd-MM-yyyy').format(parsedToDate);

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('PaperBox')
            .doc('schools')
            .collection(schoolId!)
            .doc(schoolId!)
            .collection('leave_management')
            .doc('leaves')
            .collection('student_leave')
            .doc('class')
            .collection(classNumber!)
            .add({
          'studentName': studentName,
          'section': section,
          'phoneNumber': phoneNumber,
          'fromDate': formattedFromDate,
          'leaveType': _selectedLeaveType,
          'toDate': formattedToDate,
          'comment': reason,
          'submitted_at': Timestamp.now(),
          'status': 'Pending',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Leave application submitted successfully',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ),
        );

        // Clear input fields after submission
        _fromDateController.clear();
        _toDateController.clear();
        _reasonController.clear();
        setState(() {
          _selectedLeaveType = null;
        });
      } catch (e) {
        // Handle parsing errors
        print('Error parsing date: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid date format. Please reselect the dates.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        schoolId = args?['schoolId'];
        studentName = args?['studentName'];
        phoneNumber = args?['phoneNumber'];
        classNumber = args?['class'];
        section = args?['section'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                'Leave Request',
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
              child: _buildGradientBackground(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CustomDropdownField(
                          label: "Leave Type",
                          items: leaveTypes,
                          selectedValue: _selectedLeaveType,
                          onChanged: (value) {
                            setState(() {
                              _selectedLeaveType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select section.';
                            }
                            return null;
                          },
                        ),
                        Row(children: [
                          Expanded(
                            child: CustomDateFormatField1(
                              label: "From Date",
                              controller: _fromDateController,
                              onComplete: (date) {
                                setState(() {
                                  selectedDate = date!;
                                });
                              },
                              hintText: "Select Date",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please select Date";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomDateFormatField1(
                              label: "To Date",
                              controller: _toDateController,
                              onComplete: (date) {
                                setState(() {
                                  selectedDate = date!;
                                });
                              },
                              hintText: "Select Date",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please select Date";
                                }
                                return null;
                              },
                            ),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        CustomDescriptionField(
                          label: "Comment",
                          controller: _reasonController,
                          hintText: "Comment",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Comment.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ])),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -1),
              blurRadius: 6,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFE516D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _submitLeaveApplication,
          child: Text(
            "Submit",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w400,
              height: 1.41,
            ),
          ),
        ),
      ),
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
}
