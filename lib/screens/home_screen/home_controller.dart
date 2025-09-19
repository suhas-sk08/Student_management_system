import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var studentName = ''.obs;
  var studentRollNo = ''.obs;
  var teacherName = ''.obs;
  var schoolLogoURL = ''.obs;
  var isLoading = true.obs;

  String schoolId = '';
  String phoneNumber = '';
  String classNumber = '';
  String section = '';

  void initialize({
    required String schoolId,
    required String phoneNumber,
    required String classNumber,
    required String section,
  }) {
    this.schoolId = schoolId;
    this.phoneNumber = phoneNumber;
    this.classNumber = classNumber;
    this.section = section;
    fetchStudentDetails();
    fetchSchoolLogo();
    fetchTeacherName();
  }

  Future<void> fetchStudentDetails() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('students')
          .doc('class')
          .collection(classNumber)
          .doc('section')
          .collection(section)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var studentData = snapshot.docs.first;
        studentName.value = studentData['studentName'] ?? '';
        studentRollNo.value = studentData['registrationNumber'] ?? '';
      }
    } catch (e) {
      print('Error fetching student details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTeacherName() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('sections')
          .doc('class')
          .collection(classNumber)
          .doc('section')
          .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null && data.containsKey('teachers')) {
          List<dynamic> teachers = data['teachers'];
          if (teachers.isNotEmpty) {
            teacherName.value = teachers.join(', ');
          }
        }
      }
    } catch (e) {
      print('Error fetching teacher details: $e');
    }
  }

  Future<void> fetchSchoolLogo() async {
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
          String downloadURL =
              await _storage.refFromURL(logoPath).getDownloadURL();
          schoolLogoURL.value = downloadURL;
        }
      }
    } catch (e) {
      print('Failed to fetch school logo: $e');
    }
  }
}
