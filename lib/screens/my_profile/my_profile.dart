import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:student1/constants.dart';
import 'package:student1/screens/bottom_nav/bottom_nav.dart';
import 'package:student1/screens/customField/customDisplayField.dart';
import 'package:student1/screens/login_screen/login_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen(
      {Key? key,
      required String phoneNumber,
      required String classNumber,
      required String section,
      required String schoolId})
      : super(key: key);
  static String routeName = 'MyProfileScreen';

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  List<Map<String, dynamic>>? studentData;
  bool isLoading = true;
  String? imageUrl;

  late String studentName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String schoolId = args['schoolId'];
    final String phoneNumber = args['phoneNumber'] ?? '';
    final String classNumber = args['class'] ?? '';
    final String section = args['section'] ?? '';
    _fetchStudentData(schoolId, phoneNumber, classNumber, section);
  }

  Future<void> _fetchStudentData(
    String schoolId,
    String phoneNumber,
    String classNumber,
    String section,
  ) async {
    try {
      QuerySnapshot<Map<String, dynamic>> teacherSnapshot =
          await FirebaseFirestore.instance
              .collection('PaperBox')
              .doc('schools')
              .collection(schoolId)
              .doc(schoolId)
              .collection('students')
              .doc('class')
              .collection(classNumber)
              .where('phoneNumber', isEqualTo: phoneNumber)
              .get();

      if (teacherSnapshot.docs.isNotEmpty) {
        setState(() {
          studentData = teacherSnapshot.docs.map((doc) => doc.data()).toList();
          isLoading = false;
        });

        // Fetch image after data is loaded
        await loadProfileImage();
      } else {
        _showError('No data found for this teacher');
      }
    } catch (e) {
      _showError('An error occurred while fetching data: $e');
    }
  }

  Future<void> loadProfileImage() async {
    if (studentData != null && studentData!.isNotEmpty) {
      final teacherInfo = studentData!.first;

      if (teacherInfo['profilePictureUrl'] != null &&
          teacherInfo['profilePictureUrl'].toString().isNotEmpty) {
        String? url =
            await getProfileImageUrl(teacherInfo['profilePictureUrl']);
        print(" Fetched Image URL: $url");

        if (mounted) {
          setState(() {
            imageUrl = url;
          });
        }
      }
    }
  }

  Future<String?> getProfileImageUrl(String gsUrl) async {
    try {
      print(" Fetching image from: $gsUrl");

      // Extract the path from 'gs://...' URL
      String path =
          gsUrl.replaceFirst('gs://studentapp-9f868.appspot.com/', '');

      // Get the download URL from Firebase Storage
      String downloadUrl =
          await FirebaseStorage.instance.ref(path).getDownloadURL();

      print(" Download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print(" Error fetching image URL: $e");
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences

    Navigator.pushReplacementNamed(
      context,
      LoginScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String schoolId = args['schoolId'];
    final String phoneNumber = args['phoneNumber'];
    final String classNumber = args['class'] ?? '';
    final String section = args['section'] ?? '';
    final String registrationNumber = args['registratioNumber'] ?? '';

    return Scaffold(
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 3,
          schoolId: schoolId,
          phoneNumber: phoneNumber,
          classNumber: classNumber,
          section: section,
          registrationNumber: registrationNumber,
        ),
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
            child: Column(children: [
              AppBar(
                title: Text(
                  'Profile',
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
                actions: [
                  InkWell(
                    onTap: _logout,
                    child: Container(
                      padding:
                          const EdgeInsets.only(right: kDefaultPadding / 2),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/logout.svg',
                            color: Colors.black,
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black, // Set indicator color to black
                        ),
                      )
                    : SingleChildScrollView(
                        child: _buildProfileContent(),
                      ),
              )
            ])));
  }

  Widget _buildProfileContent() {
    final studentInfo = studentData!.first;

    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 20),
      CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? NetworkImage(imageUrl!) as ImageProvider
            : null,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? Icon(Icons.person, size: 50, color: Colors.grey[600])
            : null,
      ),
      const SizedBox(height: 30),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            CustomDisplayField(
              label: "Name",
              value: studentInfo['studentName'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Date of Birth",
              value: studentInfo['dateOfBirth'] != null
                  ? DateFormat('dd-MM-yyyy').format(
                      (studentInfo['dateOfBirth'] as Timestamp).toDate())
                  : 'DOB not available',
            ),

            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Gender",
              value: studentInfo['gender'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Address",
              value: [
                studentInfo['address1'] ?? '',
                studentInfo['address2'] ?? '',
                studentInfo['address3'] ?? ''
              ].where((e) => e.isNotEmpty).join(', ').isNotEmpty
                  ? [
                      studentInfo['address1'] ?? '',
                      studentInfo['address2'] ?? '',
                      studentInfo['address3'] ?? ''
                    ].where((e) => e.isNotEmpty).join(', ')
                  : 'Address not available',
            ),

            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Contact Number",
              value: studentInfo['phoneNumber'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Blood Group",
              value: studentInfo['bloodGroup'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Nationality",
              value: studentInfo['nationality'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Religion",
              value: studentInfo['religion'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Caste",
              value: studentInfo['caste'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Caste Categary",
              value: studentInfo['Category'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Class",
              value: studentInfo['class'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Registration Number",
              value: studentInfo['registrationNumber'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Mother's Name",
              value: studentInfo['motherName'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Father's Name",
              value: studentInfo['fatherNamme'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Mother's Number",
              value: studentInfo['motherNumber'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            CustomDisplayField(
              label: "Father's Number",
              value: studentInfo['fatherNumber'] ?? 'Name not available',
            ),
            const SizedBox(height: 20),
            // Extra spacing at the bottom
          ],
        ),
      )
    ]));
  }
}
