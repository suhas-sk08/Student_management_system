import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class StudentSelectTeacherScreen extends StatefulWidget {
  final String schoolId;
  final String phoneNumber;
  final String classNumber;
  final String section;
  final String registrationNumber;
  final String studentName;
  final String teacherName;

  static String routeName = 'StudentSelectTeacherScreen';

  StudentSelectTeacherScreen({
    required this.schoolId,
    required this.phoneNumber,
    required this.classNumber,
    required this.section,
    required this.registrationNumber,
    required this.teacherName,
    required this.studentName,
  });

  @override
  _StudentSelectTeacherScreenState createState() =>
      _StudentSelectTeacherScreenState();
}

class _StudentSelectTeacherScreenState extends State<StudentSelectTeacherScreen>
    with SingleTickerProviderStateMixin {
  late String schoolId;
  late String phoneNumber;
  late String classNumber;
  late String section;
  late String registrationNumber;
  late String teacherName;
  late String studentName;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        schoolId = args?['schoolId'] ?? widget.schoolId;
        phoneNumber = args?['phoneNumber'] ?? widget.phoneNumber;
        classNumber = args?['classNumber'] ?? widget.classNumber;
        section = args?['section'] ?? widget.section;
        registrationNumber =
            args?['registrationNumber'] ?? widget.registrationNumber;
        teacherName = args?['teacherName'] ?? widget.teacherName;
        studentName = args?['studentName'] ?? widget.studentName;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // Dark Blue at the top
            Color(0xFFFFFFFF), // End with another color or transparent
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          title: const Text(
            "Chat",
            style: TextStyle(color: Colors.black),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Received Messages"),
              Tab(text: "Teachers"),
            ],
            indicatorColor: Colors.black, // Set the indicator color
            labelColor: Colors.black, // Set the selected tab text color
            unselectedLabelColor: Colors.black87,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w300,
                fontFamily: 'poppins',
                fontSize: 16,
                color: Colors.black),
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w300,
                fontFamily: 'poppins',
                fontSize: 16,
                color: Colors.black),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildReceivedMessagesTab(),
            _buildTeachersListTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessagesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('chats')
          .where('participants', arrayContains: registrationNumber)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var chatDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            var chat = chatDocs[index];
            var chatDocumentId = chat.id;
            var teacherId = chat['participants']
                .firstWhere((participant) => participant != registrationNumber);
            var teacherName = chat['teacherName'];

            return Card(
              color: Colors.grey[300]
                  ?.withOpacity(0.8), // Make the card background transparent
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Container(
                height: 75, // Adjust the height as needed
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    teacherName,
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_sharp,
                          color: Colors.black,
                        ),
                        onPressed: () =>
                            deleteChat(chatDocumentId, studentName),
                      ),
                      const Icon(
                        Icons.message_outlined,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreenStudent(
                          schoolId: schoolId,
                          studentId: registrationNumber,
                          teacherId: teacherId,
                          userId: registrationNumber,
                          userRole: 'student',
                          teacherName: teacherName,
                          studentName: studentName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeachersListTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('teachers')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var teachers = snapshot.data!.docs;

        return ListView.builder(
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            var teacher = teachers[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.grey[300]?.withOpacity(0.8),
              elevation: 5,
              child: Container(
                height: 75, // Adjust the height as needed
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    teacher['teacherName'],
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: const Icon(
                    Icons.message_outlined,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    await _createChatDocument(
                        teacher.id, teacher['teacherName']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreenStudent(
                          schoolId: schoolId,
                          studentId: registrationNumber,
                          teacherId: teacher.id,
                          userId: registrationNumber,
                          userRole: 'student',
                          teacherName: teacher['teacherName'],
                          studentName: studentName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createChatDocument(String teacherId, String teacherName) async {
    CollectionReference chatsCollection = FirebaseFirestore.instance
        .collection('PaperBox')
        .doc('schools')
        .collection(schoolId)
        .doc(schoolId)
        .collection('chats');

    DocumentReference chatDoc =
        chatsCollection.doc('${registrationNumber}_$teacherId');

    DocumentSnapshot chatSnapshot = await chatDoc.get();

    if (!chatSnapshot.exists) {
      await chatDoc.set({
        'participants': [registrationNumber, teacherId],
        'teacherName': teacherName,
        'schoolId': schoolId,
        'timestamp': Timestamp.now(),
      });
    }
  }

  void deleteChat(String chatDocumentId, String studentName) async {
    // Delete messages where studentName matches
    var messagesQuery = await FirebaseFirestore.instance
        .collection('PaperBox')
        .doc('schools')
        .collection(schoolId)
        .doc(schoolId)
        .collection('chats')
        .doc(chatDocumentId)
        .collection('messages')
        .where('studentName', isEqualTo: studentName)
        .get();

    for (var message in messagesQuery.docs) {
      await message.reference.delete();
    }

    // Delete the chat document itself
    await FirebaseFirestore.instance
        .collection('PaperBox')
        .doc('schools')
        .collection(schoolId)
        .doc(schoolId)
        .collection('chats')
        .doc(chatDocumentId)
        .delete();
  }
}
