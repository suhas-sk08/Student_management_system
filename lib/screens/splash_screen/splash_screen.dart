import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student1/screens/home_screen/home_screen.dart';
import 'package:student1/screens/login_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = 'SplashScreen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    Timer(const Duration(seconds: 8), () {
      if (mounted) {
        if (isLoggedIn) {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/images/paperbox_logo.png',
              width: 300.0,
              height: 300.0,
            ),
          ],
        ),
      ),
    );
  }
}
