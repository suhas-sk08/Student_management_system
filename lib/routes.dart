import 'package:get/get.dart';
import 'package:student1/screens/chat_screen/chat_comingsoon.dart';
import 'package:student1/screens/chat_screen/chat_screen.dart';
import 'package:student1/screens/chat_screen/teacherdisplay.dart';
import 'package:student1/screens/exam_screen/exam_screen.dart';
import 'package:student1/screens/hostel_screen/hostel.dart';
import 'package:student1/screens/leave_screen/leave_apply.dart';
import 'package:student1/screens/leave_screen/leave_summary.dart';
import 'package:student1/screens/library_screen/library_screen.dart';
import 'package:student1/screens/lms_screen/lms.dart';
import 'package:student1/screens/transport_screen/transport.dart';
import 'screens/academic_screen/academic.dart';
import 'screens/attendance_screen/attendance_screen.dart';
import 'screens/otp_input/otp_input.dart';
import 'screens/result_screen/result_screen.dart';
import 'screens/login_screen/login_screen.dart';
import 'screens/splash_screen/splash_screen.dart';
import 'screens/timetable_screen/timetable_screen.dart';
import 'screens/assignment_screen/assignment_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/fee_screen/fee_screen.dart';
import 'screens/home_screen/home_screen.dart';
import 'screens/my_profile/my_profile.dart';

List<GetPage> getPages = [
  // Student routes
  GetPage(name: '/SplashScreen', page: () => const SplashScreen()),
  GetPage(name: '/LoginScreen', page: () => LoginScreen()),
  GetPage(
      name: '/ChatComingSoon',
      page: () => ChatComingSoon(
            schoolId: '',
            phoneNumber: '',
            classNumber: '',
            section: '',
            studentName: '',
            registrationNumber: '',
          )),
  GetPage(
      name: '/HomeScreen',
      page: () => const HomeScreen(
            schoolId: '',
            phoneNumber: '',
            classNumber: '',
            section: '',
            registrationNumber: '',
          )),
  GetPage(
      name: '/LeaveSummaryScreen',
      page: () => const LeaveSummaryScreen(
            schoolId: '',
            phoneNumber: '',
            studentName: '',
            classNumber: '',
            section: '',
          )),
  GetPage(
      name: '/LeaveScreen',
      page: () => const LeaveScreen(
            schoolId: '',
            phoneNumber: '',
            studentName: '',
            classNumber: '',
            section: '',
          )),
  GetPage(name: '/FeedbackScreen', page: () => FeedbackScreen()),
  GetPage(
      name: '/MyProfileScreen',
      page: () => const MyProfileScreen(
            phoneNumber: '',
            classNumber: '',
            section: '',
            schoolId: '',
          )),
  GetPage(
      name: '/FeeScreen',
      page: () => const FeeScreen(
            schoolId: '',
            classNumber: '',
            section: '',
            studentName: '',
            registrationNumber: '',
          )),
  GetPage(
      name: '/LibraryScreen',
      page: () => const LibraryScreen(
            schoolId: '',
            classNumber: '',
            section: '',
            registrationNumber: '',
          )),
  GetPage(
      name: '/TransportScreen',
      page: () => const TransportScreen(
            schoolId: '',
            classNumber: '',
            section: '',
            studentName: '',
            registrationNumber: '',
            phoneNumber: '',
          )),
  GetPage(
      name: '/HostelScreen',
      page: () => const HostelScreen(
            schoolId: '',
            classNumber: '',
            section: '',
            studentName: '',
            registrationNumber: '',
            phoneNumber: '',
          )),
  GetPage(
      name: '/AssignmentScreen3',
      page: () => const AssignmentScreen3(
            schoolId: '',
            phoneNumber: '',
            classNumber: '',
            section: '',
          )),
  GetPage(
      name: '/NotificationsScreen', page: () => const NotificationsScreen()),
  GetPage(
      name: '/AttendanceScreen',
      page: () => const AttendanceScreen(
            schoolId: '',
            classNumber: '',
            section: '',
            registrationNumber: '',
          )),
  GetPage(
      name: '/ResultScreen',
      page: () => const ResultScreen(
            schoolId: '',
            classNumber: '',
            section: '',
            registrationNumber: '',
          )),
  GetPage(
      name: '/AcademicScreen',
      page: () => const AcademicScreen(
            schoolId: '',
            classNumber: '',
            section: '',
            registrationNumber: '',
            phoneNumber: '',
            studentName: '',
          )),
  GetPage(
      name: '/TimetableScreen',
      page: () => const TimetableScreen(
            schoolId: '',
            classNumber: '',
            section: '',
          )),
  GetPage(
      name: '/OtpInputPage',
      page: () => const OtpInputPage(
            phoneNumber: '',
            schoolId: '',
            section: '',
            classNumber: '',
            registrationNumber: '',
          )),
  GetPage(
      name: '/StudentSelectTeacherScreen',
      page: () => StudentSelectTeacherScreen(
            schoolId: '',
            registrationNumber: '',
            classNumber: '',
            section: '',
            phoneNumber: '',
            teacherName: '',
            studentName: '',
          )),
  GetPage(
      name: '/ChatScreenStudent',
      page: () => const ChatScreenStudent(
            schoolId: '',
            studentId: '',
            teacherId: '',
            userId: '',
            userRole: '',
            teacherName: '',
            studentName: '',
          )),
  GetPage(
      name: '/ExamScreen',
      page: () => const ExamScreen(
            schoolId: '',
            classNumber: '',
            section: '',
          )),
];
