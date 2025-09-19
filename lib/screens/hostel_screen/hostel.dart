import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class HostelScreen extends StatefulWidget {
  final String schoolId;
  final String classNumber;
  final String section;
  final String studentName;
  final String registrationNumber;
  final String phoneNumber;

  const HostelScreen({
    Key? key,
    required this.schoolId,
    required this.classNumber,
    required this.section,
    required this.studentName,
    required this.registrationNumber,
    required this.phoneNumber,
  }) : super(key: key);

  static String routeName = 'HostelScreen';

  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen> {
  late String schoolId;
  late String classNumber;
  late String section;
  late String studentName;
  late String registrationNumber;
  late String phoneNumber;
  String roomNo = '';
  String inchargeName = '';
  String inchargeNumber = '';
  String roomMate = '';
  String sharing = '';
  bool hasData = false;
  List<String> roomMateList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          schoolId = args['schoolId'] ?? widget.schoolId;
          classNumber = args['class'] ?? widget.classNumber;
          section = args['section'] ?? widget.section;
          studentName = args['studentName'] ?? widget.studentName;
          phoneNumber = args['phoneNumber'] ?? widget.phoneNumber;
          registrationNumber =
              args['registrationNumber'] ?? widget.registrationNumber;
        });
      } else {
        setState(() {
          schoolId = widget.schoolId;
          classNumber = widget.classNumber;
          section = widget.section;
          studentName = widget.studentName;
          phoneNumber = widget.phoneNumber;
          registrationNumber = widget.registrationNumber;
        });
      }
      _fetchRoomNo();
    });
  }

  Future<void> _fetchRoomNo() async {
    try {
      // First query: Fetch routeNo for the student
      final QuerySnapshot hostelroomSnapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('hostel_management')
          .doc('student')
          .collection('details')
          .doc('class')
          .collection(classNumber)
          .where('studentName', isEqualTo: studentName)
          .get();

      if (hostelroomSnapshot.docs.isNotEmpty) {
        final hosteroomData =
            hostelroomSnapshot.docs.first.data() as Map<String, dynamic>;

        String fetchedRoomNo = hosteroomData['roomNo'] ?? 'Not Assigned';

        setState(() {
          hasData = true;
          roomNo = fetchedRoomNo;
        });

        // Call the second query to fetch transport details
        _fetchRoomDetails(fetchedRoomNo);
      } else {
        print('No hostel records found.');
        setState(() {
          hasData = false;
          roomNo = 'Not Assigned';
        });
      }
    } catch (e) {
      print('Error fetching hostel data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching hostel data: $e'),
        ),
      );
    }
  }

  Future<void> _fetchRoomDetails(String roomNo) async {
    try {
      final QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('hostel_management')
          .doc('roomNo')
          .collection(roomNo)
          .get();

      if (roomSnapshot.docs.isNotEmpty) {
        final roomData = roomSnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          inchargeName = roomData['incharge'] ?? 'Not Available';
          inchargeNumber = roomData['inchargeNumber'] ?? 'Not Available';
          sharing = roomData['sharing'] ?? 'NA';

          // Convert to list (Handle both single & multiple roommates)
          if (roomData['roomMate'] is List) {
            roomMateList = List<String>.from(roomData['roomMate'])
                .where((mate) => mate != studentName) // Remove the current user
                .toList();
          } else {
            roomMateList = roomData['roomMate'] != studentName
                ? [roomData['roomMate']]
                : [];
          }
        });
      } else {
        print('No room details found.');
      }
    } catch (e) {
      print('Error fetching room details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching room details: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Hostel',
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
            ),
            hasData
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Ensures it doesn't take full height
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min, // Ensures it wraps content
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Room No: $roomNo',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF101828),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.40,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
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
                                  child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Prevents extra height
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Incharge',
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF667085),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  inchargeName,
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF344054),
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: -0.50,
                                                    fontSize: 16,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: 115,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Incharge’s Contact ',
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF667085),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  inchargeNumber,
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF344054),
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: -0.50,
                                                    fontSize: 16,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Room Sharing',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF667085),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              sharing,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF344054),
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: -0.50,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            if (roomMateList.isNotEmpty) ...[
                                              for (int i = 0;
                                                  i < roomMateList.length;
                                                  i += 2)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Roommate',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: const Color(
                                                                0xFF667085),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          roomMateList[i],
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: const Color(
                                                                0xFF344054),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            letterSpacing:
                                                                -0.50,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 100,
                                                    ),
                                                    // Display second roommate if available
                                                    if (i + 1 <
                                                        roomMateList.length)
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Roommate',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color: const Color(
                                                                  0xFF667085),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            roomMateList[i + 1],
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color: const Color(
                                                                  0xFF344054),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              letterSpacing:
                                                                  -0.50,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    else
                                                      const SizedBox(), // Placeholder for alignment
                                                  ],
                                                ),
                                            ] else ...[
                                              Text(
                                                'No roommates found',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ])),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: Text(
                        'No Hostel details found',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
