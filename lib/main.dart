import 'package:student1/notification_service/notification_service.dart';
import 'package:student1/routes.dart';
import 'package:student1/screens/splash_screen/splash_screen.dart';
import 'package:student1/theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student1/screens/controllers/auth_cotroller.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  Get.put(AuthController()); // Initialize AuthController00

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    NotificationServices().initialize(context);
    //it requires 3 parameters
    //context, orientation, device
    //it always requires, see plugin documentation
    return Sizer(builder: (context, orientation, device) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 0.9),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PaperBox',
          theme: CustomTheme().baseTheme,
          //initial route is splash screen
          //mean first screen
          initialRoute: SplashScreen.routeName,
          //define the routes file here in order to access the routes any where all over the app
          getPages: getPages,
        ),
      );
    });
  }
}
