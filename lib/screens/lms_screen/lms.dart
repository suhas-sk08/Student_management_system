import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatelessWidget {
  FeedbackScreen({Key? key}) : super(key: key);
  static String routeName = 'FeedbackScreen';
  TextEditingController textarea = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
            child: Column(children: [
              AppBar(
                title: const Text(
                  'LMS',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: _buildGradientBackground(
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('feedbacks')
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'Coming Soon!',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      } else {
                        final feedbacks = snapshot.data!.docs;
                        return Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(20),
                          child: ListView.builder(
                            itemCount: feedbacks.length,
                            itemBuilder: (context, index) {
                              var feedback = feedbacks[index].data()
                                  as Map<String, dynamic>;
                              return Card(
                                color: Colors.black.withOpacity(0.8),
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  title: Text(feedback['title'] ?? 'No Title'),
                                  subtitle:
                                      Text(feedback['content'] ?? 'No Content'),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              )
            ])));
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // Dark Blue at the top
            Color(0xFFFFFFFF), // Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
