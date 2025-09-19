import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:student1/screens/home_screen/home_screen.dart';

class OtpInputPage extends StatefulWidget {
  final String phoneNumber;
  final String schoolId;
  final String classNumber;
  final String section;
  final String registrationNumber;

  static String routeName = 'OtpInputPage';
  const OtpInputPage({
    Key? key,
    required this.phoneNumber,
    required this.schoolId,
    required this.classNumber,
    required this.section,
    required this.registrationNumber,
  }) : super(key: key);

  @override
  State<OtpInputPage> createState() => _OtpInputPageState();
}

class _OtpInputPageState extends State<OtpInputPage> {
  String text = '';
  bool _isLoading = false;
  bool _showError = false;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _otplessFlutterPlugin = Otpless();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {});
      }
    });
  }

  void _verifyOtp() async {
    if (text.length != 6) {
      setState(() => _showError = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    Map<String, dynamic> arg = {
      "phone": widget.phoneNumber,
      "countryCode": "+91",
      "otp": text,
    };

    _otplessFlutterPlugin.startHeadless((result) {
      setState(() => _isLoading = false);

      if (result != null && result.containsKey('responseType')) {
        var responseType = result['responseType'];
        var response = result['response'];

        if (responseType == "VERIFY" &&
            response != null &&
            response.containsKey('verification') &&
            response['verification'] == "COMPLETED") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                schoolId: widget.schoolId,
                phoneNumber: widget.phoneNumber,
                classNumber: widget.classNumber,
                section: widget.section,
                registrationNumber: widget.registrationNumber,
              ),
            ),
          );
          return;
        }
      }
    }, arg);
  }

  void _resendOtp() {
    setState(() {
      text = '';
      _showError = false;
    });

    Map<String, dynamic> arg = {
      "phone": widget.phoneNumber,
      "countryCode": "+91",
    };

    _otplessFlutterPlugin.startHeadless((result) {
      if (result.containsKey('responseType') &&
          result['responseType'] == 'INITIATE') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP sent successfully!',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send OTP. Please try again!',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }, arg);
  }

  Widget otpNumberWidget(int position) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: _showError ? Colors.red : Colors.black,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            position < text.length ? text[position] : '',
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color(0xFFFDD6B5),
              Color(0xFFFAA248),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: Stack(
          children: [
            // Top Section
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(top: 140, left: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 327,
                        child: Text(
                          'Student’s App',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF272727),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.30,
                            letterSpacing: -0.64,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 290,
                        child: Text(
                          'Create an account or log in to explore',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF272727),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.40,
                            letterSpacing: -0.12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              top: 250,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 250,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OTP Verification',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Enter the verification code we just sent to your number',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6C7278),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(_focusNode);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            6,
                            (index) => Row(
                              children: [
                                otpNumberWidget(index),
                                if (index < 5) const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Hidden TextField (captures input but remains invisible)
                      SizedBox(
                        width: 0,
                        height: 0,
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLength: 6,
                          cursorColor: Colors.transparent, // Hide cursor
                          style: const TextStyle(
                            color: Colors.transparent, // Hide text
                            fontSize: 0,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              text = value;
                              _showError = false;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 5),

                      if (_showError)
                        Text(
                          'Invalid OTP. Please try again.',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: _resendOtp,
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Didn’t receive code? ',
                                style: TextStyle(
                                  color: Color(0xFF80807F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Resend',
                                style: TextStyle(
                                  color: Color(0xFF2187D1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFFFE516D),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Verify',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.40,
                                    letterSpacing: -0.14,
                                  ),
                                ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 50,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icon/paperbox_logo.svg',
                            width: 50,
                            height: 22,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
