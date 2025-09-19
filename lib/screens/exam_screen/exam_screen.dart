import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ExamScreen extends StatefulWidget {
  static const String routeName = 'ExamScreen';
  final String schoolId;
  final String classNumber;
  final String section;

  const ExamScreen({
    Key? key,
    required this.schoolId,
    required this.classNumber,
    required this.section,
  }) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _examDataFuture;
  late String schoolId;
  late String classNumber;
  late String section;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          schoolId = args['schoolId'] ?? widget.schoolId;
          classNumber = args['class'] ?? widget.classNumber;
          section = args['section'] ?? widget.section;
        });
      } else {
        setState(() {
          schoolId = widget.schoolId;
          classNumber = widget.classNumber;
          section = widget.section;
        });
      }
      _examDataFuture = fetchExamData();
    });
  }

  Future<List<Map<String, dynamic>>> fetchExamData() async {
    try {
      print(
          'Fetching data for schoolId: $schoolId, classNumber: $classNumber, section: $section');

      // Fetch the list of exam documents
      QuerySnapshot examSnapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('exams')
          .doc('class')
          .collection(classNumber)
          .doc('section')
          .collection(section)
          .get();

      // Process each document and store the data
      List<Map<String, dynamic>> examData = [];
      for (QueryDocumentSnapshot doc in examSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Make sure 'examType' is included in the document data
        if (data.containsKey('examType')) {
          data['examType'] = data['examType'];
        } else {
          data['examType'] =
              'Unknown Exam Type'; // Fallback if examType is missing
        }
        examData.add(data);
      }

      return examData;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _examDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(),
              body: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return _buildGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(),
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(),
              body: const Center(
                child: Text(
                  'No exams available',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
          );
        } else {
          List<Map<String, dynamic>> examData = snapshot.data!;
          List<String> examTypes =
              examData.map((data) => data['examType'] as String).toList();

          return _buildGradientBackground(
            child: DefaultTabController(
              length: examTypes.length,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: _buildAppBar(
                  bottom: TabBar(
                    isScrollable: true,
                    labelColor: const Color(0xFFEE8010),
                    unselectedLabelColor: Colors.black87,
                    labelStyle: GoogleFonts.poppins(
                      color: const Color(0xFF333333),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorColor: const Color(0xFFEE8010),
                    tabs: examTypes.map((name) => Tab(text: name)).toList(),
                  ),
                ),
                body: TabBarView(
                  children:
                      examData.map((data) => _buildTimetable(data)).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  AppBar _buildAppBar({PreferredSizeWidget? bottom}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: Colors.black, // Sets the back icon color to white
      ),
      title: Text(
        'Exam Schedule',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          height: 1.41,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // Dark Blue at the top
              Color(0xFFFFFFFF), // Purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      bottom: bottom,
    );
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: child,
    );
  }

  Widget _buildTimetable(Map<String, dynamic> data) {
    List<dynamic> periodList = data['periods'] as List<dynamic>;

    return ListView.builder(
      itemCount: periodList.length,
      itemBuilder: (context, index) {
        var period = periodList[index] as Map<String, dynamic>;
        return _buildScheduleCard(period);
      },
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> data) {
    // Parse the date field
    DateTime? date;
    if (data['date'] != null) {
      date = (data['date'] as Timestamp).toDate();
    }

    // Format the date if available
    String formattedDate = 'Unknown';
    if (date != null) {
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    }

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.5, 0.8),
          colors: [Color(0xFFFAA248), Color(0xFFFDD6B5)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icon/subject.svg'),
              const SizedBox(width: 5),
              Text(
                data['subject'] ?? 'Unknown Subject',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
              const Icon(
                Icons.calendar_month_outlined,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                'Date: $formattedDate',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
              SvgPicture.asset('assets/icon/time.svg'),
              const SizedBox(width: 5),
              Text(
                'Time: ${data['startTime'] ?? 'Unknown'} - ${data['endTime'] ?? 'Unknown'}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
