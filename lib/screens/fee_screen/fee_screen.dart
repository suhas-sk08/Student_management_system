import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FeeScreen extends StatefulWidget {
  final String schoolId;
  final String classNumber;
  final String section;
  final String studentName;
  final String registrationNumber;

  const FeeScreen({
    Key? key,
    required this.schoolId,
    required this.classNumber,
    required this.section,
    required this.studentName,
    required this.registrationNumber,
  }) : super(key: key);

  static String routeName = 'FeeScreen';

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? schoolId;
  String? classNumber;
  String? section;
  String? studentName;
  String? registrationNumber;
  String? schoolLogoURL;
  int totalFeesPaid = 0;
  int remainingFees = 0;

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
          studentName = args['studentName'] ?? widget.studentName;
          registrationNumber =
              args['registrationNumber'] ?? widget.registrationNumber;
          print(
              '$schoolId $classNumber $section $registrationNumber $studentName');
        });
      } else {
        setState(() {
          schoolId = widget.schoolId;
          classNumber = widget.classNumber;
          section = widget.section;
          studentName = widget.studentName;
          registrationNumber = widget.registrationNumber;
        });
      }
      _fetchSchoolLogo(schoolId: schoolId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                'Fees Management',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.41,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
            ),
            _buildGradientBackground(
              child: Column(children: [
                // Row for the two boxes: Total Fees Paid and Remaining Fees
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: (schoolId == null ||
                          classNumber == null ||
                          registrationNumber == null)
                      ? const Center(
                          child:
                              CircularProgressIndicator()) // Show loader until values are initialized
                      : FutureBuilder<DocumentSnapshot>(
                          future: () async {
                            print("Fetching data from Firestore...");
                            return FirebaseFirestore.instance
                                .collection('PaperBox')
                                .doc('schools')
                                .collection(schoolId!)
                                .doc(schoolId!)
                                .collection('fee_management')
                                .doc('students')
                                .collection('class')
                                .doc(classNumber)
                                .collection('fees')
                                .doc(registrationNumber)
                                .get();
                          }(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              ));
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                !snapshot.data!.exists) {
                              return const Center(
                                  child: Text('No fee data found.'));
                            }
                            final feeData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final totalFeesPaid = feeData['feePaid'] ?? 0;
                            final remainingFees = feeData['balanceAmount'] ?? 0;
                            final totalFees = feeData['feeAmount'] ?? 0;
                            print('$totalFees');
                            return Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 170,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment(0.5, 0.8),
                                        colors: [
                                          Color(0xFFFFDDBD),
                                          Color(0xFFFFDDBD)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total Fee',
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF0F172A),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.43,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  '$totalFees',
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        const Color(0xFF667085),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.33,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 30,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFFE516D),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 6),
                                                ),
                                                onPressed: () {},
                                                child: Text(
                                                  "Pay Now",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: -0.30,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              _buildFeeCard(
                                                color: const Color(0xFF19B36E),
                                                label: 'Fees Paid',
                                                count: totalFeesPaid,
                                              ),
                                              const SizedBox(width: 20),
                                              _buildFeeCard(
                                                color: Colors.red,
                                                label: 'Pending',
                                                count: remainingFees,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    child: _buildReceiptTable(
                        context, classNumber!, registrationNumber!))
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptTable(
      BuildContext context, String classNumber, String registrationNumber) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId!)
          .doc(schoolId)
          .collection('fee_management')
          .doc('students')
          .collection('class')
          .doc(classNumber)
          .collection('fees')
          .doc(registrationNumber)
          .collection('fee_receipts')
          .orderBy('timestamp', descending: true) // Sort by latest first
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No receipts available',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }

        final documents = snapshot.data!.docs;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                "Fee Receipts",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                ),
              ),
              const SizedBox(height: 10),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(2),
                },
                border: TableBorder.all(color: Colors.transparent),
                children: [
                  _buildTableHeaderRow(),
                  for (var doc in documents) _buildReceiptRow(context, doc),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  TableRow _buildTableHeaderRow() {
    return TableRow(
      children: [
        _buildHeaderCell("Date"),
        _buildHeaderCell("Amount"),
        _buildHeaderCell("Mode"),
        _buildHeaderCell("Status"),
        _buildHeaderCell(""),
      ],
    );
  }

  TableRow _buildReceiptRow(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final String feesPaid = data['feesPaid'] ?? 'N/A';
    final String mode = data['mode'] ?? 'N/A';
    final String status = data['status'] ?? 'Paid';

    String formattedDate = 'N/A';
    if (data['timestamp'] != null) {
      Timestamp timestamp = data['timestamp'];
      DateTime date = timestamp.toDate();
      formattedDate = DateFormat('dd MMM').format(date);
    }

    return TableRow(
      children: [
        _buildCell(formattedDate),
        _buildCell("Rs $feesPaid"),
        _buildCell(mode),
        _buildCell(status),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: GestureDetector(
              onTap: () => _printReceipt(context, formattedDate, feesPaid, mode,
                  status, schoolLogoURL ?? ''),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Print',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF2187D1),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

//  Function to Print the Receipt
  void _printReceipt(BuildContext context, String date, String amount,
      String mode, String status, String logoUrl) async {
    final pdf = pw.Document();

    final netImage = await networkImage(logoUrl);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 80, // Adjust size as needed
                    height: 80,
                    child: pw.Image(netImage),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    "Fee Receipt",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              _buildPdfRow("Date", date),
              _buildPdfRow("Amount Paid", "Rs $amount"),
              _buildPdfRow("Payment Mode", mode),
              _buildPdfRow("Status", status),
              pw.SizedBox(height: 20),
              pw.Text("Thank you!",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

//   function for creating a row in the PDF
  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _fetchSchoolLogo({
    required String schoolId,
  }) async {
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
          String downloadURL = await FirebaseStorage.instance
              .refFromURL(logoPath)
              .getDownloadURL();
          setState(() {
            schoolLogoURL = downloadURL;
            print('School logo download URL: $schoolLogoURL');
          });
        } else {
          setState(() {
            schoolLogoURL = '';
          });
        }
      } else {
        setState(() {
          schoolLogoURL = '';
        });
      }
    } catch (e) {
      setState(() {
        schoolLogoURL = '';
      });
      print('Failed to fetch school logo: $e');
    }
  }

//   function for table header styling
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Color(0xFF0F172A),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.56,
        ),
      ),
    );
  }

//   function for table cell styling
  Widget _buildCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Color(0x7F0F172A),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.56,
        ),
      ),
    );
  }

  Widget _buildFeeCard(
      {required Color color, required String label, required int count}) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.all(16),
      width: 145,
      height: 85,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBECEE)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: ShapeDecoration(
                  color: color,
                  shape: const OvalBorder(),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF475467),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: GoogleFonts.poppins(
              color: const Color(0xFF101828),
              fontSize: 22,
              fontWeight: FontWeight.w400,
              height: 1.27,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // Dark Blue at the top
            Color(0xFFFFFFFF), // Light Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
