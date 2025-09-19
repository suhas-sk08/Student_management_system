import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Leaves {
  final String id;
  final String comment;
  final String fromDate;
  final String toDate;
  final String status;
  final DateTime submittedTime;
  final String approvedBy;
  final String leaveType;
  final String studentName;
  final String phoneNumber;
  bool isSelected; // Tracks selection

  Leaves({
    required this.id,
    required this.studentName,
    required this.comment,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.submittedTime,
    required this.approvedBy,
    required this.leaveType,
    required this.phoneNumber,
    this.isSelected = false,
  });

  factory Leaves.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime submittedTime = data['submitted_at'] != null
        ? (data['submitted_at'] as Timestamp).toDate()
        : DateTime.now();
    return Leaves(
      id: doc.id,
      studentName: data['studentName'] ?? '',
      comment: data['comment'] ?? '',
      fromDate: data['fromDate'] ?? '',
      toDate: data['toDate'] ?? '',
      submittedTime: submittedTime, // Store as DateTime
      approvedBy: data['approvedBy'] ?? '',
      status: data['status'] ?? '',
      leaveType: data['leaveType'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  /// Method to get formatted date when needed
  String get formattedSubmittedTime {
    return DateFormat('dd-MMM-yyyy').format(submittedTime);
  }

  String get formattedFromDate {
    return _formatDate(fromDate);
  }

  String get formattedToDate {
    return _formatDate(toDate);
  }

  String _formatDate(String dateStr) {
    try {
      List<String> parts = dateStr.split('-'); // Split by '-'
      if (parts.length == 3) {
        DateTime date = DateTime(
          int.parse(parts[2]), // Year
          int.parse(parts[1]), // Month
          int.parse(parts[0]), // Day
        );
        return DateFormat('dd MMM').format(date); // Convert to `dd-MMM`
      }
    } catch (e) {
      print("Error formatting date: $e");
    }
    return dateStr; // Return original if error occurs
  }
}

class LeaveReview extends StatefulWidget {
  const LeaveReview({Key? key}) : super(key: key);

  @override
  _LeaveReviewState createState() => _LeaveReviewState();
}

class _LeaveReviewState extends State<LeaveReview> {
  TextEditingController _searchController = TextEditingController();
  List<Leaves> leaves = [];
  List<Leaves> displayedLeaves = [];
  bool isLoading = false;
  String? errorMessage;
  String? schoolId;
  String? studentName;
  String? phoneNumber;
  String? classNumber;

  bool _selectAll = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        setState(() {
          schoolId = args['schoolId'];
          phoneNumber = args['phoneNumber'];
          studentName = args['studentName'];
          classNumber = args['class'];
        });

        if (schoolId != null) {
          _fetchLeaves();
        }
      }
    });
  }

  Future<void> _fetchLeaves() async {
    if (schoolId == null || classNumber == null || studentName == null) {
      setState(() {
        errorMessage = "Error: School ID is missing.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      leaves.clear();
      displayedLeaves.clear();
    });
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId!)
          .doc(schoolId)
          .collection('leave_management')
          .doc('leaves')
          .collection('student_leave')
          .doc('class')
          .collection(classNumber!)
          .where('studentName', isEqualTo: studentName)
          .where('status', isEqualTo: 'Pending')
          .get();

      List<Leaves> fetchedLeaves =
          querySnapshot.docs.map((doc) => Leaves.fromFirestore(doc)).toList();

      setState(() {
        leaves = fetchedLeaves;
        displayedLeaves = List.from(leaves);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching leaves: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            )) // Show loader while fetching
          : displayedLeaves.isEmpty
              ? Center(
                  child: Text(
                    "No Pending leaves",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ) // Show this if list is empty
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: displayedLeaves.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.only(
                            bottom: 20), // Space between containers
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icon/Group.svg',
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  displayedLeaves[index]
                                      .formattedSubmittedTime
                                      .toString(),
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF101828),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.40,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF9FAFB),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFFEAECF0)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Leave Date',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF667085),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${displayedLeaves[index].formattedFromDate} - ${displayedLeaves[index].formattedToDate}',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF344054),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.50,
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Leave Type',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF667085),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${displayedLeaves[index].leaveType}',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF344054),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.50,
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 10,
                                )
                              ],
                            ),
                          ],
                        ));
                  },
                ),
    );
  }
}
