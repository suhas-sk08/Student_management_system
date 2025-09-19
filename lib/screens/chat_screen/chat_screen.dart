import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreenStudent extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final String teacherId;
  final String userId;
  final String userRole;
  final String teacherName;
  final String studentName;

  const ChatScreenStudent({
    required this.schoolId,
    required this.studentId,
    required this.teacherId,
    required this.userId,
    required this.userRole,
    required this.teacherName,
    required this.studentName,
  });

  static String routeName = 'ChatScreenStudent';

  @override
  _ChatScreenStudentState createState() => _ChatScreenStudentState();
}

class _ChatScreenStudentState extends State<ChatScreenStudent> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String schoolId;
  late String studentId;
  late String teacherId;
  late String userId;
  late String userRole;
  late String teacherName;
  late String studentName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        schoolId = args?['schoolId'] ?? widget.schoolId;
        studentId = args?['studentId'] ?? widget.studentId;
        teacherId = args?['teacherId'] ?? widget.teacherId;
        userId = args?['userId'] ?? widget.userId;
        userRole = args?['userRole'] ?? widget.userRole;
        teacherName = args?['teacherName'] ?? widget.teacherName;
        studentName = args?['studentName'] ?? widget.studentName;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // Dark Blue at the top
            Color(0xFFFFFFFF), // End color (transparent)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          title: const Text(
            "Chat",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('PaperBox')
                    .doc('schools')
                    .collection(schoolId)
                    .doc(schoolId)
                    .collection('chats')
                    .doc('${studentId}_$teacherId')
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var chatDocs = snapshot.data!.docs;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: chatDocs.length,
                    itemBuilder: (context, index) {
                      var message = chatDocs[index];
                      bool isMe = message['senderId'] == userId;
                      return _buildMessageBubble(
                          message['message'], isMe, message['senderRole']);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(
                        color: Colors.black, // Set text color to black
                        fontSize: 16,
                      ),
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: "Enter message",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.black,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String senderRole) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[400]?.withOpacity(0.8), // Bubble background color
          borderRadius: isMe
              ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderRole == 'student' ? widget.studentName : widget.teacherName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 83, 53, 53), // Text color
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              style: const TextStyle(
                color: Colors.black, // Text color
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('PaperBox')
        .doc('schools')
        .collection(schoolId)
        .doc(schoolId)
        .collection('chats')
        .doc('${studentId}_$teacherId')
        .collection('messages')
        .add({
      'message': _controller.text,
      'senderId': userId,
      'senderRole': userRole,
      'timestamp': Timestamp.now(),
      'teacherName': teacherName,
      'studentName': studentName,
    });

    _controller.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
