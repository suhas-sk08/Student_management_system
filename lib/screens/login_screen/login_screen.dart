import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student1/screens/controllers/auth_cotroller.dart';
import 'package:student1/screens/customField/customPhoneNumber.dart';
import 'package:student1/screens/customField/customtextField.dart';
import 'package:student1/screens/home_screen/home_screen.dart';
import 'package:student1/screens/otp_input/otp_input.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = 'LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController schoolIdController = TextEditingController();
  TextEditingController phoneNumberController =
      TextEditingController(text: "+91");
  final _otplessFlutterPlugin = Otpless();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authController = Get.put(AuthController());
  @override
  void initState() {
    super.initState();
    _otplessFlutterPlugin.initHeadless("V04DB1GR8M9XU7Z8AA20");
    _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
    _checkIfLoggedIn();

    phoneNumberController.addListener(() {
      String text = phoneNumberController.text;

      // If the text already starts correctly and is valid, do nothing
      if (text.startsWith("+91 ") && text.length <= 14 && text.length >= 4) {
        return;
      }

      // Remove all non-numeric characters except the +91 prefix
      String newText = text.replaceAll(RegExp(r'[^0-9]'), '');

      // Ensure +91 remains fixed
      if (!newText.startsWith("91")) {
        newText = "91";
      }

      // Extract only 10 digits after +91
      String phoneDigits = newText.substring(2); // Remove "91" from start
      if (phoneDigits.length > 10) {
        phoneDigits = phoneDigits.substring(0, 10);
      }

      // Update text only if it needs to change
      String finalText = "+91 $phoneDigits";
      if (phoneNumberController.text != finalText) {
        phoneNumberController.text = finalText;

        // Move cursor to the correct position
        phoneNumberController.selection = TextSelection.fromPosition(
          TextPosition(offset: finalText.length),
        );
      }
    });
  }

  void onHeadlessResult(dynamic result) {
    // Handle OTP verification result here
    setState(() {
      print(result);
      // You might want to handle the result to navigate or show success/error message.
    });
  }

  Future<void> _storeUserData({
    required String schoolId,
    required String phoneNumber,
    required String classNumber,
    required String section,
    required String registrationNumber,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('schoolId', schoolId);
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('class', classNumber);
    await prefs.setString('section', section);
    await prefs.setString('registrationNumber', registrationNumber);
    await prefs.setBool('isLoggedIn', true); // Save login state
  }

  String _cleanPhoneNumber(String phone) {
    phone =
        phone.replaceAll(RegExp(r'\D'), ''); // Remove non-numeric characters

    if (phone.startsWith("91") && phone.length == 12) {
      phone = phone.substring(2); // Remove "91" prefix
    } else if (phone.startsWith("+91") && phone.length == 13) {
      phone = phone.substring(3); // Remove "+91" prefix
    }

    return phone; // Returns only the 10-digit number
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? storedSchoolId = prefs.getString('schoolId');
    String? storedPhoneNumber = prefs.getString('phoneNumber');
    String? storedClassNumber = prefs.getString('class');
    String? storedSection = prefs.getString('section');
    String? storedRegistrationNumber = prefs.getString('registrationNumber');

    if (storedSchoolId != null &&
        storedPhoneNumber != null &&
        storedClassNumber != null &&
        storedSection != null &&
        storedRegistrationNumber != null) {
      // User is already logged in, redirect to HomeScreen
      Get.offAll(() => HomeScreen(
            schoolId: storedSchoolId,
            phoneNumber: storedPhoneNumber,
            classNumber: storedClassNumber,
            section: storedSection,
            registrationNumber: storedRegistrationNumber,
          ));
    }
  }

  void _sendOtpAndRedirect(String phoneNumber, String schoolId,
      String classNumber, String section, String registrationNumber) {
    String formattedPhoneNumber = _cleanPhoneNumber(phoneNumber);

    Map<String, dynamic> arg = {
      "phone": formattedPhoneNumber,
      "countryCode": "+91",
    };

    _otplessFlutterPlugin.startHeadless((result) {
      print("OTP Response: $result"); // Debugging

      if (result['responseType'] == 'INITIATE' && result['statusCode'] == 200) {
        //  Redirect immediately to OTP Input Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpInputPage(
              phoneNumber: formattedPhoneNumber,
              schoolId: schoolId,
              classNumber: classNumber,
              section: section,
              registrationNumber: registrationNumber,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send OTP. Try again!',
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
            ),
          ),
        );
      }
    }, arg);
  }

  void onHeadlessResultDuplicate(dynamic result, String classNumber,
      String section, String registrationNumber) {
    print("Headless Result: $result"); // Debugging

    if (result['response'] != null &&
        result['response']['status'] == 'SUCCESS') {
      //  Redirect to OTP Input Page if needed
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpInputPage(
                phoneNumber: phoneNumberController.text.trim(),
                schoolId: schoolIdController.text.trim(),
                classNumber: classNumber,
                section: section,
                registrationNumber: registrationNumber),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP verification failed!',
            style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
          ),
        ),
      );
    }
  }

// Function to format phone number
  String _formatPhoneNumber(String phone) {
    if (phone.startsWith("+91") && !phone.startsWith("+91 ")) {
      return "+91 " + phone.substring(3);
    }
    return phone;
  }

  Future<void> _verifyPhoneNumber(String phoneNumber, String schoolId,
      String classNumber, String section, String registrationNumber) async {
    Map<String, dynamic> arg = {
      "phone": phoneNumber,
      "countryCode": "+91",
    };
    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);

    // Navigate to OTP input page with additional data
    Get.to(() => OtpInputPage(
          phoneNumber: phoneNumber,
          schoolId: schoolId,
          classNumber: classNumber,
          section: section,
          registrationNumber: registrationNumber,
        ));
  }

  Future<void> _checkDatabaseAndSendOtp() async {
    String schoolId = schoolIdController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();

    if (schoolId.isEmpty || phoneNumber.isEmpty) {
      print("School ID and Phone number are required");
      return;
    }

    String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

    try {
      DocumentSnapshot schoolSnapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .get();

      if (schoolSnapshot.exists) {
        QuerySnapshot usersCollection = await _firestore
            .collection('PaperBox')
            .doc('schools')
            .collection(schoolId)
            .doc(schoolId)
            .collection('users')
            .doc('students')
            .collection('details')
            .where('phoneNumber', isEqualTo: formattedPhoneNumber)
            .get();

        if (usersCollection.docs.isNotEmpty) {
          if (usersCollection.docs.length == 1) {
            // If there's only one student with the given phone number
            var userData =
                usersCollection.docs.first.data() as Map<String, dynamic>;

            // Safely access the class, section, and registrationNumber with null-aware operators
            String classNumber = userData['class'] ?? 'Unknown Class';
            String section = userData['section'] ?? 'Unknown Section';
            String registrationNumber =
                userData['registrationNumber'] ?? 'Unknown Registration';

            // Store the user data in SharedPreferences
            await _storeUserData(
              schoolId: schoolId,
              phoneNumber: phoneNumber,
              classNumber: classNumber,
              section: section,
              registrationNumber: registrationNumber,
            );
            _sendOtpAndRedirect(formattedPhoneNumber, schoolId, classNumber,
                section, registrationNumber);
          } else {
            // If there are multiple students with the same phone number
            _showStudentSelectionDialog(
                usersCollection.docs, phoneNumber, schoolId);
          }
        } else {
          print("Phone number not found in the database for this school.");
        }
      } else {
        print("School ID not found in the database.");
      }
    } catch (e) {
      print("Error checking the database: $e");
    }
  }

  void _showStudentSelectionDialog(
      List<DocumentSnapshot> studentList, String phoneNumber, String schoolId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select a Student"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                var studentData =
                    studentList[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(
                      'Class: ${studentData['class']}, Section: ${studentData['section']}'),
                  subtitle: Text(
                      'Registration Number: ${studentData['registrationNumber']}'),
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    _verifyPhoneNumber(
                      phoneNumber,
                      schoolId,
                      studentData['class'],
                      studentData['section'],
                      studentData['registrationNumber'],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color(0xFFFDD6B5),
              Color(0xFFFAA248),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: Stack(
          children: [
            // Top Section
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(top: 140, left: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 327,
                        child: Text(
                          'Student’s App',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF272727),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.30,
                            letterSpacing: -0.64,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 290,
                        child: Text(
                          'Create an account or log in to explore',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF272727),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.40,
                            letterSpacing: -0.12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Section
            Positioned(
              left: 0,
              top: 250,
              child: Container(
                width: MediaQuery.of(context).size.width, // Full width
                height: MediaQuery.of(context).size.height -
                    250, // Remaining height
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Log In Text
                      Text(
                        'Log In',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                      const SizedBox(
                          height: 24), // Space between "Log In" and input field

                      // Input Field
                      CustomTextField(
                        label: "School ID",
                        controller: schoolIdController,
                        hintText: "Enter School ID",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your School ID.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          schoolIdController.value =
                              schoolIdController.value.copyWith(
                            text: value
                                .toUpperCase(), // Convert text to uppercase
                            selection: TextSelection.collapsed(
                                offset: value.length), // Keep cursor at the end
                          );
                        },
                      ),

                      const SizedBox(
                          height: 16), // Space between "Log In" and input field

                      // Input Field
                      Customphonenumber(
                        label: "Phone Number",
                        controller: phoneNumberController,
                        hintText: "Enter your Number",
                        keyboardType: TextInputType.number, // Numeric keyboard
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Allow only numbers
                          LengthLimitingTextInputFormatter(
                              14), // Limit to "+91 " + 10 digits
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid number.';
                          }
                          if (value.length != 14) {
                            return 'Please enter a 10-digit number.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _checkDatabaseAndSendOtp();
                            // Handle Login
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFFFE516D),
                          ),
                          child: Text(
                            "Get Started",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.40,
                              letterSpacing: -0.14,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 50,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icon/paperbox_logo.svg',
                            width: 50,
                            height: 22,
                          ),
                        ),
                      )
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
}
