import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:student1/screens/leave_screen/approved_screen.dart';
import 'package:student1/screens/leave_screen/leave_apply.dart';
import 'package:student1/screens/leave_screen/pending_screen.dart';
import 'package:student1/screens/leave_screen/rejected_screen.dart';

class LeaveSummaryScreen extends StatefulWidget {
  final String schoolId;
  final String studentName;
  final String phoneNumber;
  final String classNumber;
  final String section;
  const LeaveSummaryScreen(
      {Key? key,
      required this.schoolId,
      required this.studentName,
      required this.classNumber,
      required this.section,
      required this.phoneNumber})
      : super(key: key);
  static String routeName = 'LeaveSummaryScreen';

  @override
  _LeaveSummaryScreenState createState() => _LeaveSummaryScreenState();
}

class _LeaveSummaryScreenState extends State<LeaveSummaryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? schoolId;
  String? studentName;
  String? phoneNumber;
  String? section;
  String? classNumber;
  DateTime selectedDate = DateTime.now();
  DateTime now = DateTime.now();
  int approvedLeaves = 0;
  int availableLeaves = 0;
  int totalLeaves = 0;
  String periodText = '';
  late TabController _tabController;

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
    _tabController = TabController(length: 3, vsync: this);
    int currentYear = now.year;
    int startYear, endYear;
    if (now.month >= 6) {
      startYear = currentYear;
      endYear = currentYear + 1;
    } else {
      startYear = currentYear - 1;
      endYear = currentYear;
    }
    _fromDateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
    _toDateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
    periodText = 'Period June $startYear  - April $endYear';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        schoolId = args?['schoolId'];
        phoneNumber = args?['phoneNumber'];
        studentName = args?['studentName'];
        classNumber = args?['class'];
        section = args?['section'];
      });

      fetchApprovedLeaves();
    });
  }

  void fetchApprovedLeaves() async {
    int count = await getApprovedLeavesCount();
    setState(() {
      approvedLeaves = count;
    });
  }

  Future<int> getApprovedLeavesCount() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('PaperBox')
        .doc('schools')
        .collection(schoolId!)
        .doc(schoolId!)
        .collection('leave_management')
        .doc('leaves')
        .collection('student_leave')
        .doc('class')
        .collection(classNumber!)
        .where('studentName', isEqualTo: studentName)
        .where('status', isEqualTo: 'Approved')
        .get();

    return querySnapshot.docs.length; // Return the count of approved leaves
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                'Leave Summary',
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
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_outlined),
                  color: Colors.black,
                  iconSize: 24,
                  onPressed: () {
                    Navigator.pushNamed(context, LeaveScreen.routeName,
                        arguments: {
                          'schoolId': schoolId,
                          'studentName': studentName,
                          'phoneNumber': phoneNumber,
                          'class': classNumber,
                          'section': section,
                        });
                  },
                ),
              ],
            ),
            Expanded(
              child: _buildGradientBackground(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        height: 170,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment(0.5, 0.8),
                            colors: [Color(0xFFFFDDBD), Color(0xFFFFDDBD)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Leave',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              periodText,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF667085),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.33,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildLeaveCard(
                                  color: const Color(0xFF7A5AF8),
                                  label: 'Leave Applied',
                                  count: approvedLeaves,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Add the TabBar
                      Theme(
                          data: Theme.of(context).copyWith(
                            tabBarTheme: const TabBarTheme(
                              dividerColor:
                                  Colors.transparent, // Removes the line
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              indicator: BoxDecoration(
                                color: const Color(0xFF7A5AF8),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              indicatorColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              isScrollable: false,
                              labelPadding: EdgeInsets.zero,
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                              unselectedLabelStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF475467)),
                              tabs: const [
                                Tab(text: "Review"),
                                Tab(text: "Approved"),
                                Tab(text: "Rejected"),
                              ],
                            ),
                          )),
                      // Add the TabBarView

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            LeaveReview(),
                            LeaveApproved(),
                            LeaveRejected(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget for Leave Card
  Widget _buildLeaveCard(
      {required Color color, required String label, required int count}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 310,
        height: 85,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEBECEE)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: ShapeDecoration(
                    color: color,
                    shape: const OvalBorder(),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF475467),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.33,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                color: const Color(0xFF101828),
                fontSize: 22,
                fontWeight: FontWeight.w400,
                height: 1.27,
              ),
            ),
          ],
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
