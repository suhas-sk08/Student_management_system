import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student1/screens/otp_input/otp_input.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive variables
  RxBool isSendingOTP = false.obs;
  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoggedIn = false.obs; // Track login state
  RxString errorMessage = ''.obs; // Store error messages

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
    _loadLoginState();
  }

  // Method for sending OTP and verifying phone number
  Future<void> sendOTP(String schoolId, String phoneNumber) async {
    isSendingOTP.value = true; // Start loading state
    try {
      var schoolSnapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .get();

      if (schoolSnapshot.exists) {
        var studentSnapshot = await _firestore
            .collection('PaperBox')
            .doc('schools')
            .collection(schoolId)
            .doc(schoolId)
            .collection('users')
            .doc('students')
            .collection('details')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        if (studentSnapshot.docs.isNotEmpty) {
          await _auth.verifyPhoneNumber(
            phoneNumber: phoneNumber,
            verificationCompleted: (PhoneAuthCredential credential) async {
              await _auth.signInWithCredential(credential);
              isSendingOTP.value = false;
              await _setLoginState(true);
              var userData = studentSnapshot.docs.first.data();
              await _storeUserDetails(userData);
              Get.offAllNamed('/HomeScreen');
            },
            verificationFailed: (FirebaseAuthException e) {
              isSendingOTP.value = false; // Stop loading state
              errorMessage.value =
                  'Failed to verify phone number: ${e.message}';
              Get.snackbar('Error', errorMessage.value);
            },
            codeSent: (String verificationId, int? resendToken) {
              isSendingOTP.value = false; // Stop loading state
              Get.to(() => OtpInputPage(
                    phoneNumber: phoneNumber,
                    schoolId: schoolId,
                    classNumber: '',
                    section: '',
                    registrationNumber: '',
                  ));
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              isSendingOTP.value = false; // Stop loading state
            },
          );
        } else {
          isSendingOTP.value = false; // Stop loading state
          errorMessage.value = 'Phone number not found in the students list';
          Get.snackbar('Error', errorMessage.value);
        }
      } else {
        isSendingOTP.value = false; // Stop loading state
        errorMessage.value = 'School ID not found';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      isSendingOTP.value = false; // Stop loading state
      errorMessage.value = 'Failed to send OTP: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  // Method for direct login without OTP
  Future<void> loginWithoutOTP(String schoolId, String phoneNumber) async {
    isSendingOTP.value = true; // Start loading state
    try {
      var schoolSnapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .get();

      if (schoolSnapshot.exists) {
        var studentSnapshot = await _firestore
            .collection('PaperBox')
            .doc('schools')
            .collection(schoolId)
            .doc(schoolId)
            .collection('users')
            .doc('students')
            .collection('details')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        if (studentSnapshot.docs.isNotEmpty) {
          // Phone number exists in the database, perform login
          var userData = studentSnapshot.docs.first.data();
          await _setLoginState(true);
          await _storeUserDetails(userData);
          isSendingOTP.value = false; // Stop loading state
          Get.offAllNamed('/HomeScreen');
        } else {
          isSendingOTP.value = false; // Stop loading state
          errorMessage.value = 'Phone number not found in the students list';
          Get.snackbar('Error', errorMessage.value);
        }
      } else {
        isSendingOTP.value = false; // Stop loading state
        errorMessage.value = 'School ID not found';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      isSendingOTP.value = false; // Stop loading state
      errorMessage.value = 'Failed to log in: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  // Method to store user details in SharedPreferences
  Future<void> _storeUserDetails(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userData['registrationNumber']);
    await prefs.setString('phoneNumber', userData['phoneNumber']);
    await prefs.setString('class', userData['class']);
    await prefs.setString('section', userData['section']);
  }

  // Method to log out the user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _setLoginState(false);
      Get.offAllNamed('/LoginScreen');
    } catch (e) {
      errorMessage.value = 'Failed to log out: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  // Method to set login state in SharedPreferences
  Future<void> _setLoginState(bool isLoggedIn) async {
    this.isLoggedIn.value = isLoggedIn; // Update the reactive variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);

    if (isLoggedIn) {
      var user = _auth.currentUser;
      if (user != null) {
        await prefs.setString('userId', user.uid);
        await prefs.setString('phoneNumber', user.phoneNumber ?? '');
      }
    } else {
      await prefs.remove('userId');
      await prefs.remove('phoneNumber');
    }
  }

  // Method to load login state on app startup
  Future<void> _loadLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    this.isLoggedIn.value = isLoggedIn; // Update the reactive variable
    if (isLoggedIn) {
      // Navigate to the home screen if logged in
      Get.offAllNamed('/HomeScreen');
    } else {
      // Navigate to the login screen if not logged in
      Get.offAllNamed('/LoginScreen');
    }
  }

  // Method to handle the initial screen depending on the auth state
  void _setInitialScreen(User? user) {
    if (user == null) {
      // If no user is logged in, navigate to the login screen
      Get.offAllNamed('/LoginScreen');
    } else {
      // If a user is logged in, navigate to the home screen
      Get.offAllNamed('/HomeScreen');
    }
  }
}
