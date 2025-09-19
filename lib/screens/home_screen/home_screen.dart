import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:student1/screens/academic_screen/academic.dart';
import 'package:student1/screens/academic_screen/event_list.dart';
import 'package:student1/screens/assignment_screen/assignment_screen.dart';
import 'package:student1/screens/attendance_screen/attendance_screen.dart';
import 'package:student1/screens/bottom_nav/bottom_nav.dart';
import 'package:student1/screens/chat_screen/chat_comingsoon.dart';
import 'package:student1/screens/exam_screen/exam_screen.dart';
import 'package:student1/screens/fee_screen/fee_screen.dart';
import 'package:student1/screens/hostel_screen/hostel.dart';
import 'package:student1/screens/leave_screen/leave_summary.dart';
import 'package:student1/screens/library_screen/library_screen.dart';
import 'package:student1/screens/lms_screen/lms.dart';
import 'package:student1/screens/result_screen/result_screen.dart';
import 'package:student1/screens/timetable_screen/timetable_screen.dart';
import 'package:student1/screens/transport_screen/transport.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {Key? key,
      required String schoolId,
      required String phoneNumber,
      required String classNumber,
      required String section,
      required String registrationNumber})
      : super(key: key);
  static String routeName = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String studentName = '';
  String studentRollNo = '';
  bool isLoading = true;
  String teacherName = '';
  String? schoolLogoURL;
  String? schoolId;
  String phoneNumber = '';
  String classNumber = '';
  String registrationNumber = '';
  String section = '';
  Map<String, dynamic>? homeData;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    schoolId = prefs.getString('schoolId') ?? '';
    phoneNumber = prefs.getString('phoneNumber') ?? '';
    classNumber = prefs.getString('class') ?? '';
    section = prefs.getString('section') ?? '';
    registrationNumber = prefs.getString('registrationNumber') ?? '';

    if (schoolId!.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        classNumber.isNotEmpty &&
        section.isNotEmpty) {
      await Future.wait([
        _fetchStudentDetails(
          schoolId: schoolId!,
          phoneNumber: phoneNumber,
          classNumber: classNumber,
          section: section,
        ),
        _fetchSchoolLogo(schoolId: schoolId!),
        _fetchTeacherName(
          schoolId: schoolId!,
          classNumber: classNumber,
          section: section,
        ),
      ]);
      setState(() {
        isLoading = false;
      });
    } else {
      // Navigate to login screen if user info is not available
      Navigator.pushReplacementNamed(context, 'LoginScreen');
    }
  }

  Future<void> _storeUserInfo({
    required String schoolId,
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('schoolId', schoolId);
    await prefs.setString('phoneNumber', phoneNumber);
  }

  Future<void> _fetchTeacherName({
    required String schoolId,
    required String classNumber,
    required String section,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('class&section')
          .doc('class')
          .collection(classNumber)
          .doc('section')
          .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null &&
            data.containsKey('sections') &&
            data.containsKey('teachers')) {
          List<dynamic> sections = data['sections'];
          List<dynamic> teachers = data['teachers'];

          // Find the index of the section
          int sectionIndex = sections.indexOf(section);

          // Ensure the section exists and there is a corresponding teacher
          if (sectionIndex != -1 && sectionIndex < teachers.length) {
            String fetchedTeacherName = teachers[sectionIndex];

            // Set the teacher name in the UI
            setState(() {
              teacherName = fetchedTeacherName;
            });
          } else {
            print('Section not found or no corresponding teacher.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No teacher found for the selected section.'),
              ),
            );
          }
        } else {
          print('Invalid data structure or missing fields.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Class document does not have the required fields.'),
            ),
          );
        }
      } else {
        print('Class document does not exist.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class document does not exist.'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching teacher details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching teacher details.'),
        ),
      );
    }
  }

  Future<void> _fetchStudentDetails({
    required String schoolId,
    required String phoneNumber,
    required String classNumber,
    required String section,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('students')
          .doc('class')
          .collection(classNumber)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var studentData = snapshot.docs.first.data();
        setState(() {
          studentName = studentData['studentName'] ?? '';
          studentRollNo = studentData['registrationNumber'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No student data found for this user.'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching student details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching student details.'),
        ),
      );
    }
  }

  Future<void> _fetchSchoolLogo({
    required String schoolId,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> schoolSnapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .get();

      if (schoolSnapshot.exists) {
        String? logoPath = schoolSnapshot.data()?['logoURL'] ?? '';
        if (logoPath != null && logoPath.isNotEmpty) {
          // Get the download URL from Firebase Storage
          String downloadURL = await FirebaseStorage.instance
              .refFromURL(logoPath)
              .getDownloadURL();
          setState(() {
            schoolLogoURL = downloadURL;
            print('School logo download URL: $schoolLogoURL');
          });
        } else {
          setState(() {
            schoolLogoURL = '';
          });
        }
      } else {
        setState(() {
          schoolLogoURL = '';
        });
      }
    } catch (e) {
      setState(() {
        schoolLogoURL = '';
      });
      print('Failed to fetch school logo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 0,
          schoolId: schoolId ?? '',
          phoneNumber: phoneNumber ?? '',
          classNumber: classNumber ?? '',
          section: section ?? '',
          registrationNumber: registrationNumber ?? '',
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          height: MediaQuery.of(context).size.height,
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
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 280,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFDD6B5),
                        Color(0xFFFAA248),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 18.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (schoolLogoURL != null &&
                              schoolLogoURL!.isNotEmpty)
                            Image.network(
                              schoolLogoURL!,
                              height: 70,
                              width: 70,
                            ),
                          if (schoolLogoURL == null || schoolLogoURL!.isEmpty)
                            const SizedBox.shrink(),
                          Container(
                            width: 41,
                            height: 41,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/icon/notification_icon.svg',
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Hello, ',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF272727),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.30,
                            ),
                          ),
                          Text(
                            studentName,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2A2A2A),
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.50,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Class $classNumber-$section | Roll no: $studentRollNo',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF272727),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                                letterSpacing: -0.12,
                              ),
                            ),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Teacher: $teacherName',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF272727),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                                letterSpacing: -0.12,
                              ),
                            ),
                          ]),
                      Expanded(
                        child: EventsList(
                          schoolId: schoolId!,
                          selectedDate: DateTime.now(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30), // Add spacing if needed

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      physics:
                          const BouncingScrollPhysics(), // Enable scrolling
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1,
                      children: [
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              AcademicScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section,
                                'registrationNumber': studentRollNo
                              },
                            );
                          },
                          icon: 'assets/icon/calendar_month.svg',
                          title: 'Calendar',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              AttendanceScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section,
                                'registrationNumber': studentRollNo,
                                'studentName': studentName,
                              },
                            );
                          },
                          icon: 'assets/icon/attendance_icon.svg',
                          title: 'Attendance',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              TimetableScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'studentName': studentName,
                                'class': classNumber,
                                'section': section,
                              },
                            );
                          },
                          icon: 'assets/icon/timetable_icon.svg',
                          title: 'Timetable',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              AssignmentScreen3.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section
                              },
                            );
                          },
                          icon: 'assets/icon/assignment_add.svg',
                          title: 'Assignment',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              ResultScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'studentName': studentName,
                                'class': classNumber,
                                'section': section,
                                'registrationNumber': studentRollNo,
                              },
                            );
                          },
                          icon: 'assets/icon/result_icon.svg',
                          title: 'Results',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              ExamScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'studentName': studentName,
                                'class': classNumber,
                                'section': section
                              },
                            );
                          },
                          icon: 'assets/icon/exam_schedule.svg',
                          title: 'Exam Schedule',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              FeeScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section,
                                'registrationNumber': studentRollNo,
                                'studentName': studentName,
                              },
                            );
                          },
                          icon: 'assets/icon/fee_icon.svg',
                          title: 'Fee',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              LeaveSummaryScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section,
                                'registrationNumber': studentRollNo,
                                'studentName': studentName,
                              },
                            );
                          },
                          icon: 'assets/icon/leave_icon.svg',
                          title: 'Leave ',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              TransportScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section,
                                'registrationNumber': studentRollNo,
                                'studentName': studentName,
                              },
                            );
                          },
                          icon: 'assets/icon/transport_icon.svg',
                          title: 'Transport',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              HostelScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section,
                                'registrationNumber': studentRollNo,
                                'studentName': studentName,
                              },
                            );
                          },
                          icon: 'assets/icon/hostel_icon.svg',
                          title: 'Hostel',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              LibraryScreen.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section,
                                'registrationNumber': studentRollNo,
                              },
                            );
                          },
                          icon: 'assets/icon/library_icon.svg',
                          title: 'Library',
                        ),
                        ServiceTile(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              ChatComingSoon.routeName,
                              arguments: {
                                'schoolId': schoolId,
                                'phoneNumber': phoneNumber,
                                'class': classNumber,
                                'section': section,
                                'studentName': studentName,
                                'registrationNumber': studentRollNo
                              },
                            );
                          },
                          icon: 'assets/icon/chat_icon.svg',
                          title: 'Chat',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onPress;

  const ServiceTile({
    required this.icon,
    required this.title,
    required this.onPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPress,
          child: Container(
            width: 78,
            height: 73,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              shadows: [
                const BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                )
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: _loadSvgIcon(icon),
          ),
        ),
        const SizedBox(height: 8), // Space between icon and title
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF4B4B4B),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _loadSvgIcon(String iconPath) {
    try {
      return SvgPicture.asset(
        iconPath,
        height: 32,
        width: 32,
        color: const Color(0xFFFE516D), // Adjust color if needed
      );
    } catch (e) {
      return const Icon(
        Icons.error,
        size: 32,
        color: Colors.red,
      );
    }
  }
}
