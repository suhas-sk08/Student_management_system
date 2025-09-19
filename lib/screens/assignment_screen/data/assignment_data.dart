import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentData {
  final String subjectName;
  final String topicName;
  final String assignDate;
  final String lastDate;
  final String status;

  AssignmentData({
    required this.subjectName,
    required this.topicName,
    required this.assignDate,
    required this.lastDate,
    required this.status,
  });

  factory AssignmentData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AssignmentData(
      subjectName: data['subjectName'] ?? '',
      topicName: data['topicName'] ?? '',
      assignDate: data['assignDate'] ?? '',
      lastDate: data['lastDate'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
