import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:student1/constants.dart';
import 'package:student1/screens/home_screen/home_screen.dart';

class AttendanceScreen extends StatefulWidget {
  final String schoolId;
  final String registrationNumber;
  final String classNumber;
  final String section;
  const AttendanceScreen({
    Key? key,
    required this.schoolId,
    required this.registrationNumber,
    required this.classNumber,
    required this.section,
  }) : super(key: key);

  static String routeName = 'AttendanceScreen';

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late String schoolId;
  late String registrationNumber;
  late String classNumber;
  late String section;
  int absentDays = 0;
  int totalDays = 0;
  int attendedDays = 0;
  bool hasData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
              {};
      schoolId = args['schoolId']?.toString() ?? '';
      registrationNumber = args['registrationNumber']?.toString() ?? '';
      classNumber = args['class']?.toString() ?? '';
      section = args['section']?.toString() ?? '';

      _fetchAttendanceData();
    });
  }

  Future<void> _fetchAttendanceData() async {
    try {
      print(
          'Fetching attendance data for schoolId: $schoolId, classNumber: $classNumber, section: $section, registrationNumber: $registrationNumber');
      final QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('attendance')
          .doc('class')
          .collection(classNumber)
          .doc('section')
          .collection(section)
          .doc(registrationNumber)
          .collection('date')
          .get();

      if (attendanceSnapshot.docs.isNotEmpty) {
        setState(() {
          hasData = true;
          List<Map<String, dynamic>> attendanceRecords = attendanceSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          int presentDays = attendanceRecords
              .where((record) => record['present'] == true)
              .length;
          int totalDaysCount = attendanceRecords.length;

          totalDays = totalDaysCount;
          attendedDays = presentDays;
          int absentDays = totalDaysCount - attendedDays;
        });
      } else {
        print('No attendance records found.');
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching attendance data: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
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
              'Attendance',
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
          Expanded(
              child: Container(
            width: 100.w,
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(children: [
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
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Days',
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
                                    '$totalDays',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF667085),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFE516D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      HomeScreen.routeName,
                                    );
                                  },
                                  child: Text(
                                    "View Attendance",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                ),
                              )
                            ]),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildLeaveCard(
                              color: const Color(0xFF19B36E),
                              label: 'Present',
                              count: attendedDays,
                            ),
                            const SizedBox(width: 20),
                            _buildLeaveCard(
                              color: const Color(0xFF7A5AF8),
                              label: 'Absent',
                              count: absentDays,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ))
        ],
      ),
    ));
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    Key? key,
    required this.onPress,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final VoidCallback onPress;
  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(top: 3.h),
        width: 40.w,
        height: 20.h,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.transparent, // Shadow color remains the same.
              blurRadius: 10,
            ),
          ],
          color: Colors.grey[300]
              ?.withOpacity(0.8), // Making the color transparent.
          borderRadius: BorderRadius.circular(kDefaultPadding / 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: SizerUtil.deviceType == DeviceType.tablet ? 30.sp : 40.sp,
              width: SizerUtil.deviceType == DeviceType.tablet ? 30.sp : 40.sp,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLeaveCard(
    {required Color color, required String label, required int count}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      width: 145,
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
