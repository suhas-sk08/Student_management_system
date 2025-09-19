// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableScreen extends StatefulWidget {
  static const String routeName = 'TimetableScreen';
  final String schoolId;
  final String classNumber;
  final String section;

  const TimetableScreen({
    Key? key,
    required this.schoolId,
    required this.classNumber,
    required this.section,
  }) : super(key: key);

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _timetableData = {};
  late String schoolId;
  late String classNumber;
  late String section;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
      _fetchTimetableData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTimetableData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('timetable')
          .doc('class')
          .collection(classNumber)
          .doc('section')
          .collection(section)
          .doc('weeks')
          .collection('weeks')
          .get();
      Map<String, dynamic> fetchedData = {};

      for (var doc in snapshot.docs) {
        fetchedData[doc.id] = doc.data();
      }

      setState(() {
        _timetableData = fetchedData;
      });
    } catch (error) {
      print('Error fetching timetable data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Color(0xFFEE8010),
          unselectedLabelColor: Colors.black87,
          labelStyle: GoogleFonts.poppins(
            color: Color(0xFF333333),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          indicatorColor: Color(0xFFEE8010),
          tabs: const [
            Tab(text: 'Mon'),
            Tab(text: 'Tue'),
            Tab(text: 'Wed'),
            Tab(text: 'Thu'),
            Tab(text: 'Fri'),
            Tab(text: 'Sat'),
          ],
        ),
      ),
      body: _buildGradientBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDayTasks('Monday'),
            _buildDayTasks('Tuesday'),
            _buildDayTasks('Wednesday'),
            _buildDayTasks('Thursday'),
            _buildDayTasks('Friday'),
            _buildDayTasks('Saturday'),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // Dark Blue at the top
            Color(0xFFFFFFFF), // Light Blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }

  AppBar _buildAppBar({PreferredSizeWidget? bottom}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: Colors.black, // Sets the back icon color
      ),
      title: Text(
        'Timetable',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          height: 1.41,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(color: Colors.white),
      ),
      bottom: bottom,
    );
  }

  Widget _buildDayTasks(String day) {
    if (_timetableData.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      );
    }

    // Get the day's data; each day document has a 'periods' list
    final dayData = _timetableData[day] ?? {};
    final periods = dayData['periods'] as List<dynamic>? ?? [];

    if (periods.isEmpty) {
      return Center(
        child: Text(
          'No timetable available for $day',
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(15),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        final period = periods[index] as Map<String, dynamic>;
        return _buildScheduleCard(period);
      },
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> data) {
    return Container(
      height: 146,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${data['period'] ?? 'Unknown'}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${data['class'] ?? 'Unknown'}${data['section'] ?? 'Unknown'}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icon/subject.svg'),
              SizedBox(width: 5),
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
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icon/user_right.svg'),
              SizedBox(width: 5),
              Text(
                data['teacher'] ?? 'Unknown teacher',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icon/time.svg'),
              SizedBox(width: 5),
              Text(
                '${data['startTime'] ?? 'Unknown'} - ${data['endTime'] ?? 'Unknown'}',
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
