import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class TransportScreen extends StatefulWidget {
  final String schoolId;
  final String classNumber;
  final String section;
  final String studentName;
  final String registrationNumber;
  final String phoneNumber;

  const TransportScreen({
    Key? key,
    required this.schoolId,
    required this.classNumber,
    required this.section,
    required this.studentName,
    required this.registrationNumber,
    required this.phoneNumber,
  }) : super(key: key);

  static String routeName = 'TransportScreen';

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  late String schoolId;
  late String classNumber;
  late String section;
  late String studentName;
  late String registrationNumber;
  late String phoneNumber;
  String route = '';
  String inchargeName = '';
  String inchargeNumber = '';
  String driverName = '';
  String driverNumber = '';
  bool hasData = false;

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
      _fetchTransportDetails();
    });
  }

  Future<void> _fetchTransportDetails() async {
    try {
      // First query: Fetch routeNo for the student
      final QuerySnapshot transportSnapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('transport')
          .doc('student')
          .collection('details')
          .doc('class')
          .collection(classNumber)
          .where('studentName', isEqualTo: studentName)
          .get();

      if (transportSnapshot.docs.isNotEmpty) {
        final transportData =
            transportSnapshot.docs.first.data() as Map<String, dynamic>;

        String fetchedRouteNo = transportData['routeNo'] ?? 'Not Assigned';

        setState(() {
          hasData = true;
          route = fetchedRouteNo;
        });

        // Call the second query to fetch transport details
        _fetchRouteDetails(fetchedRouteNo);
      } else {
        print('No transport records found.');
        setState(() {
          hasData = false;
          route = 'Not Assigned';
        });
      }
    } catch (e) {
      print('Error fetching transport data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching transport data: $e'),
        ),
      );
    }
  }

  Future<void> _fetchRouteDetails(String routeNo) async {
    try {
      final QuerySnapshot routeSnapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('transport')
          .doc('routes')
          .collection(routeNo) // Using the fetched route number
          .get();

      if (routeSnapshot.docs.isNotEmpty) {
        final routeData =
            routeSnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          inchargeName = routeData['incharge'] ?? 'Not Available';
          inchargeNumber = routeData['inchargeNumber'] ?? 'Not Available';
          driverName = routeData['driverName'] ?? 'Not Available';
          driverNumber = routeData['driverNumber'] ?? 'Not Available';
        });
      } else {
        print('No route details found.');
      }
    } catch (e) {
      print('Error fetching route details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching route details: $e'),
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
                'Transport',
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
                                      'Mode School Bus : (No $route)',
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
                                  mainAxisSize:
                                      MainAxisSize.min, // Prevents extra height
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Incharge',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF667085),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              inchargeName,
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
                                              'Incharge’s Contact ',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF667085),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              inchargeNumber,
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
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Driver’s Name',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF667085),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              driverName,
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
                                              'Driver’s Contact',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF667085),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              driverNumber,
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
                                    )
                                  ],
                                ),
                              ),
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
                        'No transport details found',
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
