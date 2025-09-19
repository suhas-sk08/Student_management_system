import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future attendanceDetails(
      Map<String, dynamic> attendanceInfo, String id) async {
    return await FirebaseFirestore.instance
        .collection("attendance")
        .doc(id)
        .set(attendanceInfo);
  }

  Future<Stream<QuerySnapshot>> getStudentDetails() async {
    return await FirebaseFirestore.instance.collection("students").snapshots();
  }
}
